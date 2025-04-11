/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 2025

   Parser with semantic actions for interpretation */

%{
#include <iostream>
#include <vector>
#include <cmath>
#include <string>
#include "values.h"
#include "listing.h"
using namespace std;

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* message);

double result;
%}


%union {
    char* lexeme;
    double value;
    vector<double>* vec;
    Operators oper;
}

%token <lexeme> IDENTIFIER
%token <lexeme> INT_LITERAL CHAR_LITERAL
%token FUNCTION RETURNS BEGIN_ END IF THEN ELSE ENDIF
%token FOLD LEFT RIGHT ENDFOLD
%token AND OR NOT
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUAL NOTEQUAL

%type <value> Goal FunctionBody
%type <value> Expression
%type <vec> ValueList
%type <oper> Operator

%left OR
%left AND
%left EQUAL NOTEQUAL
%left LESS LESSEQUAL GREATER GREATEREQUAL
%left '+' '-'
%left '*' '/' '%'
%right '^'
%right NOT NEGATE

%%

Goal:
    FunctionHeader FunctionBody END ';'
    {
        cout << "Compiled Successfully" << endl;
        cout << "Result = " << $2 << endl;
    }
;

FunctionHeader:
    FUNCTION IDENTIFIER ParameterList RETURNS IDENTIFIER ';'
;

ParameterList:
    IDENTIFIER ':' IDENTIFIER
    | ParameterList ',' IDENTIFIER ':' IDENTIFIER
;

FunctionBody:
    BEGIN_ Expression
    {
        $$ = $2;
    }
;

Expression:
      INT_LITERAL                        { $$ = strtol($1, nullptr, 0); }
    | CHAR_LITERAL                       { $$ = (double)$1[0]; }
    | Expression '+' Expression          { $$ = evaluateArithmetic($1, ADD, $3); }
    | Expression '-' Expression          { $$ = evaluateArithmetic($1, SUBTRACT, $3); }
    | Expression '*' Expression          { $$ = evaluateArithmetic($1, MULTIPLY, $3); }
    | Expression '/' Expression          { $$ = evaluateArithmetic($1, DIVIDE, $3); }
    | Expression '%' Expression          { $$ = evaluateArithmetic($1, REMAINDER, $3); }
    | Expression '^' Expression          { $$ = evaluateArithmetic($1, EXPONENT, $3); }
    | '-' Expression %prec NEGATE        { $$ = evaluateNegation($2); }
    | Expression LESS Expression         { $$ = evaluateRelational($1, LESS, $3); }
    | Expression LESSEQUAL Expression    { $$ = evaluateRelational($1, LESSEQUAL, $3); }
    | Expression GREATER Expression      { $$ = evaluateRelational($1, GREATER, $3); }
    | Expression GREATEREQUAL Expression { $$ = evaluateRelational($1, GREATEREQUAL, $3); }
    | Expression EQUAL Expression        { $$ = evaluateRelational($1, EQUAL, $3); }
    | Expression NOTEQUAL Expression     { $$ = evaluateRelational($1, NOTEQUAL, $3); }
    | Expression AND Expression          { $$ = evaluateLogical($1, AND, $3); }
    | Expression OR Expression           { $$ = evaluateLogical($1, OR, $3); }
    | NOT Expression                     { $$ = evaluateLogical($2, NOT, 0); }
    | '(' Expression ')'                 { $$ = $2; }
    | IF Expression THEN Expression ELSE Expression ENDIF { $$ = $2 ? $4 : $6; }
    | FOLD LEFT Operator '(' ValueList ')' ENDFOLD        { $$ = evaluateFold(LEFT_DIR, $3, $5); delete $5; }
    | FOLD RIGHT Operator '(' ValueList ')' ENDFOLD       { $$ = evaluateFold(RIGHT_DIR, $3, $5); delete $5; }
;

ValueList:
      Expression                         { $$ = new vector<double>(); $$->push_back($1); }
    | ValueList ',' Expression           { $$ = $1; $$->push_back($3); }
;

Operator:
      '+' { $$ = ADD; }
    | '-' { $$ = SUBTRACT; }
    | '*' { $$ = MULTIPLY; }
    | '/' { $$ = DIVIDE; }
    | '%' { $$ = REMAINDER; }
    | '^' { $$ = EXPONENT; }
    | AND { $$ = AND; }
    | OR  { $$ = OR; }
;

%%

void yyerror(const char* message) {
    appendError(SYNTAX, message);
}

