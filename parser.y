/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 13, 2025 */
   
/* This file defines the Bison parser for a custom language with 
   semantic actions for the interpreter */

%{
#include <iostream>
#include <cmath>
#include <string>
#include <vector>
#include <map>
#include <cstdlib>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);
double extract_element(CharPtr list_name, double subscript);
double evaluateFold(Operators oper, vector<double>* list, bool isLeft);
int hexToInt(const char* hexStr);
char parseCharLiteral(const char* literal);

Symbols<double> scalars;
Symbols<vector<double>*> lists;
double result;
double* parameters = NULL;

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

%token <oper> ADDOP MULOP REMOP EXPOP NEGOP ANDOP OROP NOTOP RELOP

%token ARROW

%token BEGIN_ CASE CHARACTER ELSE ELSIF END ENDIF ENDSWITCH ENDFOLD FOLD FUNCTION IF
	INTEGER IS LEFT LIST OF OTHERS REAL RETURNS RIGHT SWITCH THEN WHEN

%type <value> body statement_ statement cases case expression term factor primary
	 unary_expression condition or_condition and_condition not_condition relation else_clause
	 if_statement switch_statement direction

%type <list> list expressions list_choice

%%

function:	
	function_header variables body ';' {result = $3;} ;
	
function_header:	
	FUNCTION IDENTIFIER parameters RETURNS type ';' |
	FUNCTION IDENTIFIER RETURNS type ';' ;

parameters:
	parameter |
	parameters ',' parameter |
	%empty ;

parameter:
	IDENTIFIER ':' type {int i = scalars.getNextParameterIndex();
                         scalars.insert($1, parameters[i]);} ;

type:
	INTEGER |
	REAL |
	CHARACTER ;
	
variables:
	variables variable |
	%empty ;
	
variable:	
	IDENTIFIER ':' type IS statement ';' {scalars.insert($1, $5);} |
	IDENTIFIER ':' LIST OF type IS list ';' {lists.insert($1, $7);} ;

list:
	'(' expressions ')' {$$ = $2;} ;

expressions:
	expressions ',' expression {$1->push_back($3); $$ = $1;} | 
	expression {$$ = new vector<double>(); $$->push_back($1);}

body:
	BEGIN_ statement_ END {$$ = $2;} ;

statement_:
	statement ';' {$$ = $1;} |
	error ';' {$$ = 0;} ;
    
statement:
	expression {$$ = $1;} |
	WHEN condition ',' expression ':' expression {$$ = $2 ? $4 : $6;} |
	switch_statement {$$ = $1;} |
	if_statement {$$ = $1;} |
	FOLD direction ADDOP list_choice ENDFOLD {$$ = evaluateFold($3, $4, $2 == LEFT);} |
	FOLD direction MULOP list_choice ENDFOLD {$$ = evaluateFold($3, $4, $2 == LEFT);} ;

switch_statement:
	SWITCH expression IS cases OTHERS ARROW statement_ ENDSWITCH
		{$$ = !isnan($4) ? $4 : $7;} ;

if_statement:
	IF condition THEN statement_ elsif_list else_clause ENDIF {$$ = $2 ? $4 : $6;} ;

elsif_list:
	elsif_list ELSIF condition THEN statement_ {if (!$1 && $3) $<value>$ = $5;} |
	%empty {$<value>$ = 0;} ;

else_clause:
	ELSE statement_ {$$ = $2;} |
	%empty {$$ = 0;} ;

direction:
	LEFT {$$ = LEFT;} |
	RIGHT {$$ = RIGHT;} ;

list_choice:
	list {$$ = $1;} |
	IDENTIFIER {vector<double>* list;
                if (lists.find($1, list)) $$ = list;
                else {
                    appendError(UNDECLARED, $1);
                    $$ = new vector<double>();
                }} ;

cases:
	cases case {$$ = !isnan($1) ? $1 : $2;} |
	%empty {$$ = NAN;} ;
	
case:
	CASE INT_LITERAL ARROW statement_ {$$ = $<value>-2 == $2 ? $4 : NAN;} ; 

condition:
	or_condition {$$ = $1;} ;

or_condition:
	or_condition OROP and_condition {$$ = $1 || $3;} |
	and_condition {$$ = $1;} ;

and_condition:
	and_condition ANDOP not_condition {$$ = $1 && $3;} |
	not_condition {$$ = $1;} ;

not_condition:
	NOTOP not_condition {$$ = !$2;} |
	'(' condition ')' {$$ = $2;} |
	relation {$$ = $1;} ;

relation:
	expression RELOP expression {$$ = evaluateRelational($1, $2, $3);} ;

expression:
	expression ADDOP term {$$ = evaluateArithmetic($1, $2, $3);} |
	term {$$ = $1;} ;
      
term:
	term MULOP factor {$$ = evaluateArithmetic($1, $2, $3);} |
	term REMOP factor {$$ = evaluateArithmetic($1, $2, $3);} |
	factor {$$ = $1;} ;

factor:
	factor EXPOP unary_expression {$$ = evaluateArithmetic($1, $2, $3);} |
	unary_expression {$$ = $1;} ;

unary_expression:
	NEGOP unary_expression {$$ = -$2;} |
	primary {$$ = $1;} ;

primary:
	'(' expression ')' {$$ = $2;} |
	INT_LITERAL {$$ = $1;} | 
	REAL_LITERAL {$$ = $1;} |
	CHAR_LITERAL {$$ = $1;} |
	IDENTIFIER '(' expression ')' {$$ = extract_element($1, $3);} |
	IDENTIFIER {if (!scalars.find($1, $$)) appendError(UNDECLARED, $1);} ;

%%

void yyerror(const char* message) {
	appendError(SYNTAX, message);
}

double extract_element(CharPtr list_name, double subscript) {
	vector<double>* list; 
	if (lists.find(list_name, list))
		return (*list)[int(subscript)];
	appendError(UNDECLARED, list_name);
	return NAN;
}

double evaluateFold(Operators oper, vector<double>* list, bool isLeft) {
    if (list->size() == 0)
        return 0;
    if (list->size() == 1)
        return (*list)[0];
    
    double result;
    
    if (isLeft) {
        // Left fold ((a op b) op c)
        result = (*list)[0];
        for (size_t i = 1; i < list->size(); i++)
            result = evaluateArithmetic(result, oper, (*list)[i]);
    } else {
        // Right fold (a op (b op c))
        result = (*list)[list->size() - 1];
        for (int i = list->size() - 2; i >= 0; i--)
            result = evaluateArithmetic((*list)[i], oper, result);
    }
    
    return result;
}

int hexToInt(const char* hexStr) {
    // Skip the '#' prefix
    return strtol(hexStr + 1, NULL, 16);
}

char parseCharLiteral(const char* literal) {
    if (literal[1] != '\\')
        return literal[1];
    
    // Handle escape characters
    switch(literal[2]) {
        case 'n': return '\n';
        case 't': return '\t';
        case 'r': return '\r';
        case 'f': return '\f';
        case 'b': return '\b';
        default: return literal[2];
    }
}

int main(int argc, char *argv[]) {
    // Handle command line parameters
    if (argc > 1) {
        parameters = new double[argc - 1];
        for (int i = 1; i < argc; i++) {
            parameters[i - 1] = atof(argv[i]);
        }
    }
    
	firstLine();
	yyparse();
	if (lastLine() == 0)
		cout << "Result = " << result << endl;
    
    // Clean up
    if (parameters != NULL)
        delete[] parameters;
        
	return 0;
}
