%{
#include <string>
using namespace std;
#include "listing.h"
int yylex();
void yyerror(const char* message);
%}

%error-verbose

%token IDENTIFIER
%token INT_LITERAL
%token REAL_LITERAL
%token BOOL_LITERAL
%token ADDOP MULOP RELOP ANDOP OROP REMOP EXPOP
%token BEGIN_ BOOLEAN END ENDREDUCE FUNCTION INTEGER IS REDUCE RETURNS
%left ANDOP
%left OROP
%nonassoc RELOP
%left ADDOP
%left MULOP
%right EXPOP
%right NOT

%%

function:  
    function_header optional_variable body ';' 
    ;

function_header:  
    FUNCTION IDENTIFIER parameters RETURNS type ';' 
    | FUNCTION IDENTIFIER RETURNS type ';' error
    ;

parameters: 
    /* empty */ 
    | parameter_list 
    ;

parameter_list: 
    parameter
    | parameter_list ',' parameter
    ;

parameter: 
    IDENTIFIER ':' type
    ;

optional_variable:
    variable_list
    | /* empty */
    ;

variable_list:
    variable
    | variable_list variable
    ;

variable:
    IDENTIFIER ':' type IS statement
    | IDENTIFIER ':' type error IS statement
    ;

type:
    INTEGER
    | REAL
    | BOOLEAN
    ;

body:
    BEGIN_ statement_list END
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    expression ';'
    | REDUCE operator reductions ENDREDUCE
    | IF expression THEN statement ELSE statement ENDIF
    | CASE expression IS case_list OTHERS ARROW statement ENDCASE
    | error ';'
    ;

reductions:
    reduction
    | reductions reduction
    ;

reduction:
    statement
    ;

case_list:
    case
    | case_list case
    ;

case:
    WHEN INT_LITERAL ARROW statement
    ;

expression:
    '(' expression ')'
    | REAL_LITERAL
    | INT_LITERAL
    | BOOL_LITERAL
    | IDENTIFIER
    | NOT expression
    | expression binary_operator expression
    ;

binary_operator:
    ADDOP
    | MULOP
    | REMOP
    | EXPOP
    | RELOP
    | ANDOP
    | OROP
    ;

%%

void yyerror(const char* message)
{
    appendError(SYNTAX, message);
}

int main(int argc, char *argv[])
{
    firstLine();
    yyparse();
    lastLine();
    return 0;
}
