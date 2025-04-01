/*‏‏‎ ‎CMSC‏‏‎ ‎430‏‏‎ ‎Project‏‏‎ ‎2‏‏‎ ‎-‏‏‎ ‎Syntactic‏‏‎ ‎Analyzer‏‏‎ ‎*/
/*‏‏‎ ‎Compiler‏‏‎ ‎Theory‏‏‎ ‎and‏‏‎ ‎Design‏‏‎ ‎*/

%{
#include‏‏‎ ‎<string>
using‏‏‎ ‎namespace‏‏‎ ‎std;

#include‏‏‎ ‎"listing.h"

int‏‏‎ ‎yylex();
void‏‏‎ ‎yyerror(const‏‏‎ ‎char*‏‏‎ ‎message);
%}

%define‏‏‎ ‎parse.error‏‏‎ ‎verbose

%token‏‏‎ ‎IDENTIFIER
%token‏‏‎ ‎INT_LITERAL
%token‏‏‎ ‎REAL_LITERAL

%token‏‏‎ ‎ADDOP‏‏‎ ‎MULOP‏‏‎ ‎EXPOP‏‏‎ ‎RELOP‏‏‎ ‎ANDOP‏‏‎ ‎OROP
%token‏‏‎ ‎NOTOP

%token‏‏‎ ‎BEGIN_‏‏‎ ‎BOOLEAN‏‏‎ ‎END‏‏‎ ‎ENDREDUCE‏‏‎ ‎FUNCTION‏‏‎ ‎INTEGER‏‏‎ ‎IS‏‏‎ ‎REDUCE‏‏‎ ‎RETURNS
%token‏‏‎ ‎CASE‏‏‎ ‎WHEN‏‏‎ ‎ARROW‏‏‎ ‎OTHERS‏‏‎ ‎ENDCASE‏‏‎ ‎IF‏‏‎ ‎THEN‏‏‎ ‎ELSE‏‏‎ ‎ENDIF

%%

function:‏‏‎ ‎‏‏‎ ‎
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎function_header‏‏‎ ‎optional_variable‏‏‎ ‎body‏‏‎ ‎;
‏‏‎ ‎‏‏‎ ‎
function_header:‏‏‎ ‎‏‏‎ ‎
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎FUNCTION‏‏‎ ‎IDENTIFIER‏‏‎ ‎RETURNS‏‏‎ ‎type‏‏‎ ‎';'
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎error‏‏‎ ‎';'‏‏‎ ‎‏‏‎ ‎/*‏‏‎ ‎Error‏‏‎ ‎recovery‏‏‎ ‎using‏‏‎ ‎semicolon‏‏‎ ‎*/
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

optional_variable:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎variable‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

variable:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎IDENTIFIER‏‏‎ ‎':'‏‏‎ ‎type‏‏‎ ‎IS‏‏‎ ‎statement
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎error‏‏‎ ‎';'‏‏‎ ‎‏‏‎ ‎/*‏‏‎ ‎Error‏‏‎ ‎recovery‏‏‎ ‎using‏‏‎ ‎semicolon‏‏‎ ‎*/
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

type:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎INTEGER‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎BOOLEAN‏‏‎ ‎;

body:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎BEGIN_‏‏‎ ‎statement_list‏‏‎ ‎END‏‏‎ ‎';'‏‏‎ ‎;
‏‏‎ ‎‏‏‎ ‎
statement_list:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎statement_list‏‏‎ ‎statement_‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎statement_‏‏‎ ‎;

statement_:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎statement‏‏‎ ‎';'‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎error‏‏‎ ‎';'‏‏‎ ‎;‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎/*‏‏‎ ‎Error‏‏‎ ‎recovery‏‏‎ ‎using‏‏‎ ‎semicolon‏‏‎ ‎*/
‏‏‎ ‎‏‏‎ ‎
statement:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎expression‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎REDUCE‏‏‎ ‎operator‏‏‎ ‎reductions‏‏‎ ‎ENDREDUCE‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎IF‏‏‎ ‎expression‏‏‎ ‎THEN‏‏‎ ‎statement‏‏‎ ‎ELSE‏‏‎ ‎statement‏‏‎ ‎ENDIF‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎CASE‏‏‎ ‎expression‏‏‎ ‎IS‏‏‎ ‎case_list‏‏‎ ‎OTHERS‏‏‎ ‎ARROW‏‏‎ ‎statement‏‏‎ ‎ENDCASE‏‏‎ ‎;

operator:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎ADDOP‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎MULOP‏‏‎ ‎;

reductions:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎reductions‏‏‎ ‎statement_‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎
case_list:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎case_list‏‏‎ ‎case_‏‏‎ ‎|
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎case_‏‏‎ ‎;

case_:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎WHEN‏‏‎ ‎INT_LITERAL‏‏‎ ‎ARROW‏‏‎ ‎statement
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎error‏‏‎ ‎';'‏‏‎ ‎‏‏‎ ‎/*‏‏‎ ‎Error‏‏‎ ‎recovery‏‏‎ ‎using‏‏‎ ‎semicolon‏‏‎ ‎*/
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;
‏‏‎ ‎‏‏‎ ‎
expression:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎logical_or_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

logical_or_expr:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎logical_or_expr‏‏‎ ‎OROP‏‏‎ ‎logical_and_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎logical_and_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

logical_and_expr:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎logical_and_expr‏‏‎ ‎ANDOP‏‏‎ ‎equality_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎equality_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

equality_expr:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎equality_expr‏‏‎ ‎RELOP‏‏‎ ‎additive_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎additive_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

additive_expr:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎additive_expr‏‏‎ ‎ADDOP‏‏‎ ‎multiplicative_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎multiplicative_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

multiplicative_expr:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎multiplicative_expr‏‏‎ ‎MULOP‏‏‎ ‎exponential_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎exponential_expr
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

exponential_expr:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎primary‏‏‎ ‎EXPOP‏‏‎ ‎primary
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎primary
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

primary:
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎'('‏‏‎ ‎expression‏‏‎ ‎')'
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎NOTOP‏‏‎ ‎primary
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎INT_LITERAL
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎REAL_LITERAL
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎|‏‏‎ ‎IDENTIFIER
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎;

%%

void‏‏‎ ‎yyerror(const‏‏‎ ‎char*‏‏‎ ‎message)
{
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎appendError(SYNTAX,‏‏‎ ‎message);
}

int‏‏‎ ‎main(int‏‏‎ ‎argc,‏‏‎ ‎char‏‏‎ ‎*argv[])
{
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎firstLine();
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎yyparse();
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎lastLine();
‏‏‎ ‎‏‏‎ ‎‏‏‎ ‎return‏‏‎ ‎0;
}
