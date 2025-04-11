/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 2025

   Parser with semantic actions for interpretation */

%{
#include <iostream>
#include <cmath>
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);
double extract_element(CharPtr list_name, double subscript);

Symbols<double> scalars;
Symbols<vector<double>*> lists;
double result;

vector<double> parameterValues;
int paramIndex = 0;
%}

%define parse.error verbose

%union {
    CharPtr iden;
    Operators oper;
    double value;
    vector<double>* list;
}

%token <iden> IDENTIFIER
%token <value> INT_LITERAL REAL_LITERAL CHAR_LITERAL
%token <oper> ADDOP MULOP REMOP EXPOP NEGOP
%token <oper> ANDOP OROP NOTOP
%token <oper> RELOP
%token ARROW
%token BEGIN_ CASE CHARACTER ELSE ELSIF END ENDIF ENDSWITCH ENDFOLD FOLD FUNCTION IF
%token INTEGER IS LEFT LIST OF OTHERS REAL RETURNS RIGHT SWITCH THEN WHEN

%type <value> function function_header type body statement_ statement switch_statement if_statement elsif_list else_clause cases case expression term factor unary_expression primary condition or_condition and_condition not_condition relation variable direction
%type <list> list expressions
%type <value> list_choice
%type <oper> operator

%%
function:
    function_header variables body ';' { result = $3; } ;

function_header:
    FUNCTION IDENTIFIER parameters RETURNS type ';' {
        paramIndex = 0;
        $$ = 0;
    } |
    FUNCTION IDENTIFIER RETURNS type ';' {
        $$ = 0;
    } ;

parameters:
    parameter |
    parameters ',' parameter |
    %empty ;

parameter:
    IDENTIFIER ':' type {
        if (paramIndex < parameterValues.size()) {
            scalars.insert($1, parameterValues[paramIndex++]);
        } else {
            appendError(GENERAL_SEMANTIC, "Missing parameter value");
        }
        $$ = 0;
    } ;

variables:
    variables variable { $$ = 0; } |
    %empty { $$ = 0; } ;

variable:
    IDENTIFIER ':' type IS statement ';' { 
        scalars.insert($1, $5); 
        $$ = 0;
    } |
    IDENTIFIER ':' LIST OF type IS list ';' { 
        lists.insert($1, $7); 
        $$ = 0;
    } |
    error ';' { $$ = 0; } ;

list:
    '(' expressions ')' { $$ = $2; } ;

expressions:
    expressions ',' expression { $1->push_back($3); $$ = $1; } |
    expression { $$ = new vector<double>(); $$->push_back($1); } ;

type:
    INTEGER { $$ = 0; } |
    REAL { $$ = 0; } |
    CHARACTER { $$ = 0; } ;

body:
    BEGIN_ statement_ END { $$ = $2; } ;

statement_:
    statement ';' { $$ = $1; } | 
    error ';' { $$ = 0; } ;

statement:
    expression { $$ = $1; } |
    WHEN condition ',' expression ':' expression { $$ = $2 ? $4 : $6; } |
    switch_statement { $$ = $1; } |
    if_statement { $$ = $1; } |
    FOLD direction operator list_choice ENDFOLD {
        $$ = evaluateFold($2, $3, (vector<double>*)$4);
    } ;

switch_statement:
    SWITCH expression IS cases OTHERS ARROW statement_ ENDSWITCH {
        $$ = !isnan($4) ? $4 : $7;
    } ;

if_statement:
    IF condition THEN statement_ elsif_list else_clause ENDIF {
        if ($2)
            $$ = $4;
        else if (!isnan($5))
            $$ = $5;
        else
            $$ = $6;
    } ;

elsif_list:
    elsif_list ELSIF condition THEN statement_ { 
        if (isnan($1) && $3)
            $$ = $5;
        else
            $$ = $1;
    } |
    %empty { $$ = NAN; } ;

else_clause:
    ELSE statement_ { $$ = $2; } |
    %empty { $$ = NAN; } ;

cases:
    cases case { $$ = !isnan($1) ? $1 : $2; } |
    case { $$ = $1; } ;

case:
    CASE INT_LITERAL ARROW statement_ { $$ = ($<value>-2 == $2) ? $4 : NAN; } |
    error ';' { $$ = NAN; } ;

direction:
    LEFT { $$ = LEFT_DIR; } |
    RIGHT { $$ = RIGHT_DIR; } ;

operator:
    ADDOP { $$ = $1; } | 
    MULOP { $$ = $1; } | 
    REMOP { $$ = $1; } | 
    EXPOP { $$ = $1; } ;

list_choice:
    list { $$ = (double)(intptr_t)$1; } | 
    IDENTIFIER {
        vector<double>* listVal;
        if (!lists.find($1, listVal)) {
            appendError(UNDECLARED, $1);
            $$ = 0;
        } else {
            $$ = (double)(intptr_t)listVal;
        }
    } ;

condition:
    or_condition { $$ = $1; } ;

or_condition:
    or_condition OROP and_condition { $$ = $1 || $3; } |
    and_condition { $$ = $1; } ;

and_condition:
    and_condition ANDOP not_condition { $$ = $1 && $3; } |
    not_condition { $$ = $1; } ;

not_condition:
    NOTOP not_condition { $$ = !$2; } |
    '(' condition ')' { $$ = $2; } |
    relation { $$ = $1; } ;

relation:
    expression RELOP expression { $$ = evaluateRelational($1, $2, $3); } ;

expression:
    expression ADDOP term { $$ = evaluateArithmetic($1, $2, $3); } |
    term { $$ = $1; } ;

term:
    term MULOP factor { $$ = evaluateArithmetic($1, $2, $3); } |
    term REMOP factor { $$ = evaluateArithmetic($1, $2, $3); } |
    factor { $$ = $1; } ;

factor:
    factor EXPOP unary_expression { $$ = evaluateArithmetic($1, $2, $3); } |
    unary_expression { $$ = $1; } ;

unary_expression:
    NEGOP unary_expression { $$ = evaluateNegation($2); } |
    primary { $$ = $1; } ;

primary:
    '(' expression ')' { $$ = $2; } |
    INT_LITERAL { $$ = $1; } |
    REAL_LITERAL { $$ = $1; } |
    CHAR_LITERAL { $$ = $1; } |
    IDENTIFIER '(' expression ')' { 
        $$ = extract_element($1, $3); 
    } |
    IDENTIFIER {
        double value;
        if (!scalars.find($1, value)) {
            appendError(UNDECLARED, $1);
            $$ = 0;
        } else {
            $$ = value;
        }
    } ;

%%

void yyerror(const char* message) {
    appendError(SYNTAX, message);
}

double extract_element(CharPtr list_name, double subscript) {
    vector<double>* list;
    if (lists.find(list_name, list)) {
        int index = static_cast<int>(subscript);
        if (index >= 0 && index < list->size())
            return (*list)[index];
        appendError(GENERAL_SEMANTIC, "List index out of bounds");
        return NAN;
    }
    appendError(UNDECLARED, list_name);
    return NAN;
}

int main(int argc, char *argv[]) {
    // Process command line arguments as parameters
    for (int i = 1; i < argc; i++)
        parameterValues.push_back(atof(argv[i]));

    firstLine();
    yyparse();
    if (lastLine() == 0)
        cout << "Result = " << result << endl;
    return 0;
}
