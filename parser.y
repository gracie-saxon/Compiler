/* CMSC 430 Compiler Theory and Design
   Project 4
   Gracie Saxon
   April 29, 2025 */
   
/* This file defines the Bison parser for the compiler with semantic actions for type checking */

%{
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

int yylex();
Types find(Symbols<Types>& table, CharPtr identifier, string tableName);
void checkDuplicate(Symbols<Types>& table, CharPtr identifier, string tableName);
void yyerror(const char* message);

Symbols<Types> scalars;
Symbols<Types> lists;

%}

%define parse.error verbose

%union {
    CharPtr iden;
    Types type;
    vector<Types>* typeList;
}

%token <iden> IDENTIFIER
%token <type> INT_LITERAL CHAR_LITERAL REAL_LITERAL
%token ADDOP MULOP REMOP EXPOP NEGOP
%token RELOP ANDOP OROP NOTOP
%token ARROW
%token BEGIN_ CASE CHARACTER ELSE ELSIF END ENDIF ENDSWITCH ENDFOLD FOLD FUNCTION IF
%token INTEGER IS LEFT LIST OF OTHERS REAL RETURNS RIGHT SWITCH THEN WHEN

%type <type> list expressions body type statement_ statement cases case expression
    term factor primary unary_expression function_header condition relation or_condition
    and_condition not_condition elsif_list else_clause if_statement switch_statement
    list_choice direction operator

%type <typeList> expression_list

%%

function:
    function_header variables body {
        checkAssignment($1, $3, "Function Return");
        if ($1 == INT_TYPE && $3 == REAL_TYPE)
            appendError(GENERAL_SEMANTIC, "Illegal Narrowing Function Return");
    };

function_header:
    FUNCTION IDENTIFIER RETURNS type ';' { $$ = $4; } |
    FUNCTION IDENTIFIER parameters RETURNS type ';' { $$ = $5; } |
    error ';' { $$ = MISMATCH; };

parameters:
    parameter |
    parameters ',' parameter |
    %empty;

parameter:
    IDENTIFIER ':' type;

variables:
    variables variable |
    %empty;

variable:
    IDENTIFIER ':' type IS statement ';' {
        checkDuplicate(scalars, $1, "Scalar");
        checkAssignment($3, $5, "Variable Initialization");
        if ($3 == INT_TYPE && $5 == REAL_TYPE)
            appendError(GENERAL_SEMANTIC, "Illegal Narrowing Variable Initialization");
        scalars.insert($1, $3);
    } |
    IDENTIFIER ':' LIST OF type IS list ';' {
        checkDuplicate(lists, $1, "List");
        checkListType($5, $7);
        lists.insert($1, $5);
    } |
    error ';';

list:
    '(' expressions ')' { $$ = $2; };

expressions:
    expression_list {
        if ($1->size() > 0) {
            Types firstType = (*$1)[0];
            bool allSame = true;
            
            for (size_t i = 1; i < $1->size(); i++) {
                if ((*$1)[i] != firstType) {
                    allSame = false;
                    break;
                }
            }
            
            if (!allSame)
                appendError(GENERAL_SEMANTIC, "List Element Types Do Not Match");
                
            $$ = firstType;
        } else {
            $$ = NONE;
        }
        delete $1;
    };

expression_list:
    expression_list ',' expression {
        $1->push_back($3);
        $$ = $1;
    } |
    expression {
        $$ = new vector<Types>;
        $$->push_back($1);
    };

type:
    INTEGER { $$ = INT_TYPE; } |
    REAL { $$ = REAL_TYPE; } |
    CHARACTER { $$ = CHAR_TYPE; };

body:
    BEGIN_ statement_ END ';' { $$ = $2; };

statement_:
    statement ';' { $$ = $1; } |
    error ';' { $$ = MISMATCH; };

statement:
    expression { $$ = $1; } |
    WHEN condition ',' expression ':' expression {
        $$ = checkWhen($4, $6);
    } |
    if_statement { $$ = $1; } |
    switch_statement { $$ = $1; } |
    FOLD direction operator list_choice ENDFOLD {
        if (!checkFoldList($4))
            $$ = MISMATCH;
        else
            $$ = $4;
    };

switch_statement:
    SWITCH expression IS cases OTHERS ARROW statement_ ENDSWITCH {
        $$ = checkSwitch($2, $4, $7);
    };

if_statement:
    IF condition THEN statement_ elsif_list else_clause ENDIF {
        if ($5 == NONE)
            $$ = checkIfStatement($4, $6);
        else
            $$ = checkIfStatement(checkIfStatement($4, $5), $6);
    };

elsif_list:
    elsif_list ELSIF condition THEN statement_ {
        if ($1 == NONE)
            $$ = $5;
        else
            $$ = checkIfStatement($1, $5);
    } |
    %empty { $$ = NONE; };

else_clause:
    ELSE statement_ { $$ = $2; } |
    %empty { $$ = NONE; };

cases:
    cases case { $$ = checkCases($1, $2); } |
    %empty { $$ = NONE; };

case:
    CASE INT_LITERAL ARROW statement_ { $$ = $4; } |
    error ';' { $$ = MISMATCH; };

direction:
    LEFT { $$ = INT_TYPE; } |
    RIGHT { $$ = INT_TYPE; };

operator:
    ADDOP { $$ = INT_TYPE; } |
    MULOP { $$ = INT_TYPE; };

list_choice:
    list { $$ = $1; } |
    IDENTIFIER { $$ = find(lists, $1, "List"); };

condition:
    or_condition { $$ = $1; };

or_condition:
    or_condition OROP and_condition { $$ = $1; } |
    and_condition { $$ = $1; };

and_condition:
    and_condition ANDOP not_condition { $$ = $1; } |
    not_condition { $$ = $1; };

not_condition:
    NOTOP not_condition { $$ = $2; } |
    '(' condition ')' { $$ = $2; } |
    relation { $$ = $1; };

relation:
    expression RELOP expression {
        checkCharacterComparison($1, $3);
        $$ = INT_TYPE;
    };

expression:
    expression ADDOP term {
        $$ = checkArithmetic($1, $3);
    } |
    term { $$ = $1; };

term:
    term MULOP factor {
        $$ = checkArithmetic($1, $3);
    } |
    term REMOP factor {
        if (!checkRemainder($1, $3))
            $$ = MISMATCH;
        else
            $$ = INT_TYPE;
    } |
    factor { $$ = $1; };

factor:
    factor EXPOP unary_expression {
        Types result = checkArithmetic($1, $3);
        if (result == MISMATCH)
            $$ = MISMATCH;
        else
            $$ = result;
    } |
    unary_expression { $$ = $1; };

unary_expression:
    NEGOP unary_expression {
        if ($2 != INT_TYPE && $2 != REAL_TYPE) {
            appendError(GENERAL_SEMANTIC, "Arithmetic Operator Requires Numeric Types");
            $$ = MISMATCH;
        } else {
            $$ = $2;
        }
    } |
    primary { $$ = $1; };

primary:
    '(' expression ')' { $$ = $2; } |
    INT_LITERAL |
    REAL_LITERAL |
    CHAR_LITERAL |
    IDENTIFIER '(' expression ')' {
        Types listType = find(lists, $1, "List");
        if (listType != MISMATCH) {
            if (!checkListSubscript($3))
                $$ = MISMATCH;
            else
                $$ = listType;
        } else {
            $$ = MISMATCH;
        }
    } |
    IDENTIFIER { $$ = find(scalars, $1, "Scalar"); };

%%

Types find(Symbols<Types>& table, CharPtr identifier, string tableName) {
    Types type;
    if (!table.find(identifier, type)) {
        appendError(UNDECLARED, tableName + " " + identifier);
        return MISMATCH;
    }
    return type;
}

void checkDuplicate(Symbols<Types>& table, CharPtr identifier, string tableName) {
    Types type;
    if (table.find(identifier, type)) {
        appendError(DUPLICATE_IDENTIFIER, tableName + " " + identifier);
    }
}

void yyerror(const char* message) {
    appendError(SYNTAX, message);
}

int main(int argc, char *argv[]) {
    firstLine();
    yyparse();
    lastLine();
    return 0;
}
