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

// Forward declarations for types
typedef char* CharPtr;
enum Operators {
    ADD, SUBTRACT, MULTIPLY, DIVIDE, REMAINDER, EXPONENT, NEGATE,
    LESS, LESSEQUAL, GREATER, GREATEREQUAL, EQUAL, NOTEQUAL,
    AND, OR, NOT
};
enum Direction { LEFT_DIR, RIGHT_DIR };

#include "listing.h"
#include "symbols.h"

// Function declarations
int yylex();
void yyerror(const char* message);
double extract_element(CharPtr list_name, double subscript);
double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);
double evaluateLogical(double left, Operators operator_, double right);
double evaluateNegation(double value);
double evaluateFold(Direction dir, Operators oper, vector<double>* values);

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
%type <list> list expressions list_choice

%%
function:
    function_header variables body ';' { result = $3; } ;

function_header:
    FUNCTION IDENTIFIER parameters RETURNS type ';' {
        paramIndex = 0;
    } |
    FUNCTION IDENTIFIER RETURNS type ';' ;

parameters:
    parameter |
    parameters ',' parameter |
    %empty ;

parameter:
    IDENTIFIER ':' type {
        if (paramIndex < parameterValues.size()) {
            scalars.insert($1, parameterValues[paramIndex++]);
        } else {
            appendError(GENERAL_SEMANTIC, "Not enough parameter values provided");
        }
    } ;

variables:
    variables variable |
    %empty ;

variable:
    IDENTIFIER ':' type IS statement ';' { scalars.insert($1, $5); } |
    IDENTIFIER ':' LIST OF type IS list ';' { lists.insert($1, $7); } |
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
    statement ';' | error ';' { $$ = 0; } ;

statement:
    expression { $$ = $1; } |
    WHEN condition ',' expression ':' expression { $$ = $2 ? $4 : $6; } |
    switch_statement { $$ = $1; } |
    if_statement { $$ = $1; } |
    FOLD direction ADDOP list_choice ENDFOLD { $$ = evaluateFold($2, $3, $4); } |
    FOLD direction MULOP list_choice ENDFOLD { $$ = evaluateFold($2, $3, $4); } |
    FOLD direction REMOP list_choice ENDFOLD { $$ = evaluateFold($2, $3, $4); } |
    FOLD direction EXPOP list_choice ENDFOLD { $$ = evaluateFold($2, $3, $4); } ;

switch_statement:
    SWITCH expression IS cases OTHERS ARROW statement_ ENDSWITCH {
        $$ = !isnan($4) ? $4 : $7;
    } ;

if_statement:
    IF condition THEN statement_ elsif_list else_clause ENDIF {
        $$ = $2 ? $4 : (!isnan($5) ? $5 : $6);
    } ;

elsif_list:
    elsif_list ELSIF condition THEN statement_ { 
        if (isnan($$) && $3) {
            $$ = $5;
        }
    } |
    %empty { $$ = NAN; } ;

else_clause:
    ELSE statement_ { $$ = $2; } |
    %empty { $$ = NAN; } ;

cases:
    cases case { $$ = !isnan($1) ? $1 : $2; } |
    case ;

case:
    CASE INT_LITERAL ARROW statement_ { $$ = ($<value>-2 == $2) ? $4 : NAN; } |
    error ';' { $$ = NAN; } ;

direction:
    LEFT { $$ = LEFT_DIR; } |
    RIGHT { $$ = RIGHT_DIR; } ;

list_choice:
    list { $$ = $1; } | 
    IDENTIFIER {
        vector<double>* listVal;
        if (!lists.find($1, listVal)) {
            appendError(UNDECLARED, $1);
            $$ = new vector<double>();
        } else {
            $$ = listVal;
        }
    } ;

condition:
    or_condition ;

or_condition:
    or_condition OROP and_condition { $$ = $1 || $3; } |
    and_condition ;

and_condition:
    and_condition ANDOP not_condition { $$ = $1 && $3; } |
    not_condition ;

not_condition:
    NOTOP not_condition { $$ = !$2; } |
    '(' condition ')' { $$ = $2; } |
    relation ;

relation:
    expression RELOP expression { $$ = evaluateRelational($1, $2, $3); } ;

expression:
    expression ADDOP term { $$ = evaluateArithmetic($1, $2, $3); } |
    term ;

term:
    term MULOP factor { $$ = evaluateArithmetic($1, $2, $3); } |
    term REMOP factor { $$ = evaluateArithmetic($1, $2, $3); } |
    factor ;

factor:
    factor EXPOP unary_expression { $$ = evaluateArithmetic($1, $2, $3); } |
    unary_expression ;

unary_expression:
    NEGOP unary_expression { $$ = evaluateNegation($2); } |
    primary ;

primary:
    '(' expression ')' { $$ = $2; } |
    INT_LITERAL |
    REAL_LITERAL |
    CHAR_LITERAL |
    IDENTIFIER '(' expression ')' { 
        vector<double>* list;
        if (lists.find($1, list)) {
            int index = static_cast<int>($3);
            if (index >= 0 && index < list->size()) {
                $$ = (*list)[index];
            } else {
                appendError(GENERAL_SEMANTIC, "Index out of bounds");
                $$ = NAN;
            }
        } else {
            appendError(UNDECLARED, $1);
            $$ = NAN;
        }
    } |
    IDENTIFIER {
        if (!scalars.find($1, $$)) appendError(UNDECLARED, $1);
    } ;

%%

void yyerror(const char* message) {
    appendError(SYNTAX, message);
}

double extract_element(CharPtr list_name, double subscript) {
    vector<double>* list;
    if (lists.find(list_name, list)) {
        int index = static_cast<int>(subscript);
        if (index >= 0 && index < list->size()) {
            return (*list)[index];
        }
        appendError(GENERAL_SEMANTIC, "Index out of bounds");
        return NAN;
    }
    appendError(UNDECLARED, list_name);
    return NAN;
}

// Implementation of evaluateArithmetic
double evaluateArithmetic(double left, Operators operator_, double right) {
    switch (operator_) {
        case ADD: return left + right;
        case SUBTRACT: return left - right;
        case MULTIPLY: return left * right;
        case DIVIDE: 
            if (right != 0) 
                return left / right; 
            else {
                appendError(GENERAL_SEMANTIC, "Division by zero");
                return NAN;
            }
        case REMAINDER: 
            if (right != 0) 
                return static_cast<int>(left) % static_cast<int>(right);
            else {
                appendError(GENERAL_SEMANTIC, "Modulo by zero");
                return NAN;
            }
        case EXPONENT: return pow(left, right);
        default: 
            appendError(GENERAL_SEMANTIC, "Invalid arithmetic operator");
            return NAN;
    }
}

// Implementation of evaluateRelational
double evaluateRelational(double left, Operators operator_, double right) {
    switch (operator_) {
        case LESS: return left < right;
        case LESSEQUAL: return left <= right;
        case GREATER: return left > right;
        case GREATEREQUAL: return left >= right;
        case EQUAL: return left == right;
        case NOTEQUAL: return left != right;
        default: 
            appendError(GENERAL_SEMANTIC, "Invalid relational operator");
            return NAN;
    }
}

// Implementation of evaluateLogical
double evaluateLogical(double left, Operators operator_, double right) {
    switch (operator_) {
        case AND: return left && right;
        case OR: return left || right;
        default: 
            appendError(GENERAL_SEMANTIC, "Invalid logical operator");
            return NAN;
    }
}

// Implementation of evaluateNegation
double evaluateNegation(double value) {
    return -value;
}

// Implementation of evaluateFold
double evaluateFold(Direction dir, Operators oper, vector<double>* values) {
    if (!values || values->empty()) {
        appendError(GENERAL_SEMANTIC, "Empty list in fold operation");
        return NAN;
    }

    // Handle single element lists
    if (values->size() == 1) {
        return (*values)[0];
    }

    double result;
    
    if (dir == LEFT_DIR) {
        // Left fold: ((a op b) op c) op d...
        result = (*values)[0];
        for (size_t i = 1; i < values->size(); ++i) {
            result = evaluateArithmetic(result, oper, (*values)[i]);
            if (isnan(result)) {
                return NAN; // Error occurred in evaluation
            }
        }
    } else {
        // Right fold: a op (b op (c op d...))
        result = (*values)[values->size() - 1];
        for (int i = values->size() - 2; i >= 0; --i) {
            result = evaluateArithmetic((*values)[i], oper, result);
            if (isnan(result)) {
                return NAN; // Error occurred in evaluation
            }
        }
    }

    return result;
}

int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++)
        parameterValues.push_back(atof(argv[i]));

    firstLine();
    yyparse();
    if (lastLine() == 0)
        cout << "Result = " << result << endl;
    return 0;
}
