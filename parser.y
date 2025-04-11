/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 2025

   Parser with semantic actions for interpretation */

%{
#include <iostream>
#include <cmath>
#include <vector>        // <--- Needed for std::vector
#include <string>
#include "values.h"      // <--- Needed for enum Operators
#include "listing.h"     // <--- For appendError

using namespace std;

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* message);

double result;
%}

%token <lexeme> IDENTIFIER
%token <lexeme> INT_LITERAL CHAR_LITERAL
%token FUNCTION RETURNS BEGIN_ END IF THEN ELSE ENDIF
%token FOLD LEFT RIGHT ENDFOLD
%token AND OR NOT
%token LESS LESSEQUAL GREATER GREATEREQUAL EQUAL NOTEQUAL

%union {
    char* lexeme;
    double value;
    std::vector<double>* vec;
    Operators oper;
}

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
    | Expression '+' Expression          { $$ = evaluateArithmetic($1, OP_ADD, $3); }
    | Expression '-' Expression          { $$ = evaluateArithmetic($1, OP_SUBTRACT, $3); }
    | Expression '*' Expression          { $$ = evaluateArithmetic($1, OP_MULTIPLY, $3); }
    | Expression '/' Expression          { $$ = evaluateArithmetic($1, OP_DIVIDE, $3); }
    | Expression '%' Expression          { $$ = evaluateArithmetic($1, OP_REMAINDER, $3); }
    | Expression '^' Expression          { $$ = evaluateArithmetic($1, OP_EXPONENT, $3); }
    | '-' Expression %prec NEGATE        { $$ = evaluateNegation($2); }
    | Expression LESS Expression         { $$ = evaluateRelational($1, OP_LESS, $3); }
    | Expression LESSEQUAL Expression    { $$ = evaluateRelational($1, OP_LESSEQUAL, $3); }
    | Expression GREATER Expression      { $$ = evaluateRelational($1, OP_GREATER, $3); }
    | Expression GREATEREQUAL Expression { $$ = evaluateRelational($1, OP_GREATEREQUAL, $3); }
    | Expression EQUAL Expression        { $$ = evaluateRelational($1, OP_EQUAL, $3); }
    | Expression NOTEQUAL Expression     { $$ = evaluateRelational($1, OP_NOTEQUAL, $3); }
    | Expression AND Expression          { $$ = evaluateLogical($1, OP_AND, $3); }
    | Expression OR Expression           { $$ = evaluateLogical($1, OP_OR, $3); }
    | NOT Expression                     { $$ = evaluateLogical($2, OP_NOT, 0); }
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
      '+' { $$ = OP_ADD; }
    | '-' { $$ = OP_SUBTRACT; }
    | '*' { $$ = OP_MULTIPLY; }
    | '/' { $$ = OP_DIVIDE; }
    | '%' { $$ = OP_REMAINDER; }
    | '^' { $$ = OP_EXPONENT; }
    | AND { $$ = OP_AND; }
    | OR  { $$ = OP_OR; }
    | NOT { $$ = OP_NOT; }
    | LESS { $$ = OP_LESS; }
    | LESSEQUAL { $$ = OP_LESSEQUAL; }
    | GREATER { $$ = OP_GREATER; }
    | GREATEREQUAL { $$ = OP_GREATEREQUAL; }
    | EQUAL { $$ = OP_EQUAL; }
    | NOTEQUAL { $$ = OP_NOTEQUAL; }
;

%%

void yyerror(const char* message) {
    appendError(SYNTAX, message);
}

