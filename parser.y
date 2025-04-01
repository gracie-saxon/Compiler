/* CMSC 430 Compiler Theory and Design
   Project 2
   Gracie Saxon
   April 1, 2025 */

%{
#include <string>
using namespace std;
#include "listing.h"
int yylex();
void yyerror(const char* message);
%}

%define parse.error verbose

%token IDENTIFIER INT_LITERAL REAL_LITERAL CHAR_LITERAL
%token ADDOP MULOP REMOP EXPOP NEGOP
%token ANDOP OROP NOTOP RELOP ARROW
%token BEGIN_ CASE CHARACTER ELSE ELSIF END ENDIF ENDSWITCH ENDFOLD FOLD FUNCTION IF
%token INTEGER IS LEFT LIST OF OTHERS REAL RETURNS RIGHT SWITCH THEN WHEN

%%
function:
    function_header variables body ;

function_header:
    FUNCTION IDENTIFIER parameters RETURNS type ';' |
    FUNCTION IDENTIFIER RETURNS type ';' |
    error ';' ;

parameters:
    parameter |
    parameters ',' parameter |
    %empty ;

parameter:
    IDENTIFIER ':' type ;

variables:
    variables variable |
    %empty ;

variable:
    IDENTIFIER ':' type IS statement ';' |
    IDENTIFIER ':' LIST OF type IS list ';' |
    error ';' ;

list:
    '(' expressions ')' ;

expressions:
    expression |
    expressions ',' expression ;

type:
    INTEGER |
    REAL |
    CHARACTER ;

body:
    BEGIN_ statement_ END ';' ;

statement_:
    statement ';' |
    error ';' ;

statement:
    expression |
    WHEN condition ',' expression ':' expression |
    switch_statement |
    if_statement |
    FOLD direction operator list_choice ENDFOLD ;

switch_statement:
    SWITCH expression IS cases OTHERS ARROW statement_ ENDSWITCH ;

if_statement:
    IF condition THEN statement_ elsif_list else_clause ENDIF ;

elsif_list:
    elsif_list ELSIF condition THEN statement_ |
    %empty ;

else_clause:
    ELSE statement_ |
    %empty ;

cases:
    cases case |
    case ;

case:
    CASE INT_LITERAL ARROW statement_ |
    error ';' ;

direction:
    LEFT |
    RIGHT ;

operator:
    ADDOP |
    MULOP ;

list_choice:
    list |
    IDENTIFIER ;

condition:
    or_condition ;

or_condition:
    or_condition OROP and_condition |
    and_condition ;

and_condition:
    and_condition ANDOP not_condition |
    not_condition ;

not_condition:
    NOTOP not_condition |
    '(' condition ')' |
    relation ;

relation:
    expression RELOP expression ;

expression:
    expression ADDOP term |
    term ;

term:
    term MULOP factor |
    term REMOP factor |
    factor ;

factor:
    factor EXPOP unary_expression |
    unary_expression ;

unary_expression:
    NEGOP unary_expression |
    primary ;

primary:
    '(' expression ')' |
    INT_LITERAL |
    REAL_LITERAL |
    CHAR_LITERAL |
    IDENTIFIER '(' expression ')' |
    IDENTIFIER ;

%%

void yyerror(const char* message) {
    appendError(SYNTAX, message);
}

int main(int argc, char *argv[]) {
    firstLine();
    yyparse();
    lastLine();
    return 0;
}
