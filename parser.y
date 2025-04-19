/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 19, 2025 */
   
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

// Forward declarations for functions defined in values.cc
extern int hexToInt(const char* hexStr);
extern char parseCharLiteral(const char* literal);

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
	INTEGER IS LEFT_DIR LIST OF OTHERS REAL RETURNS RIGHT_DIR SWITCH THEN WHEN

%type <value> body statement_ statement cases case expression term factor primary
	 unary_expression condition or_condition and_condition not_condition relation else_clause
	 if_statement switch_statement direction elsif_list

%type <list> list expressions list_choice

/* Define operator precedence - lowest to highest */
%left OROP
%left ANDOP
%right NOTOP
%left RELOP
%left ADDOP
%left MULOP REMOP
%right EXPOP
%right NEGOP

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
	IF condition THEN statement_ elsif_list else_clause ENDIF {$$ = $2 ? $4 : ($5 != 0 ? $5 : $6);} ;

elsif_list:
	elsif_list ELSIF condition THEN statement_ {$$ = ($1 != 0) ? $1 : ($3 ? $5 : 0);} |
	%empty {$$ = 0;} ;

else_clause:
	ELSE statement_ {$$ = $2;} |
	%empty {$$ = 0;} ;

direction:
	LEFT_DIR {$$ = LEFT;} |
	RIGHT_DIR {$$ = RIGHT;} ;

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
	unary_expression EXPOP factor {$$ = evaluateArithmetic($1, $2, $3);} |
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
        result = (*list)[0];
        for (size_t i = 1; i < list->size(); i++)
            result = evaluateArithmetic(result, oper, (*list)[i]);
    } else {
        result = (*list)[list->size() - 1];
        for (int i = list->size() - 2; i >= 0; i--)
            result = evaluateArithmetic((*list)[i], oper, result);
    }
    
    return result;
}

int main(int argc, char *argv[]) {
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
    
    if (parameters != NULL)
        delete[] parameters;
        
	return 0;
}
