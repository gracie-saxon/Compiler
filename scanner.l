/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 2025

   This file contains the Flex input for lexical analysis */

%{
#include "listing.h"
#include "parser.tab.h"
#include <string>
using namespace std;
%}

DIGIT       [0-9]
HEXDIGIT    [0-9a-fA-F]
ID          [a-zA-Z][a-zA-Z0-9]*

%%

{DIGIT}+                    { yylval.lexeme = strdup(yytext); return INT_LITERAL; }
0[xX]{HEXDIGIT}+           { yylval.lexeme = strdup(yytext); return INT_LITERAL; }

'\\n'                       { yylval.lexeme = strdup("\n"); return CHAR_LITERAL; }
'\\t'                       { yylval.lexeme = strdup("\t"); return CHAR_LITERAL; }
'\\''                       { yylval.lexeme = strdup("'"); return CHAR_LITERAL; }
'\\\\'                      { yylval.lexeme = strdup("\\"); return CHAR_LITERAL; }
'\''[^'\\]'\''              {
                             char* val = new char[2];
                             val[0] = yytext[1];
                             val[1] = '\0';
                             yylval.lexeme = val;
                             return CHAR_LITERAL;
                           }

"function"                  { return FUNCTION; }
"returns"                   { return RETURNS; }
"begin"                     { return BEGIN_; }
"end"                       { return END; }
"if"                        { return IF; }
"then"                      { return THEN; }
"else"                      { return ELSE; }
"endif"                     { return ENDIF; }
"fold"                      { return FOLD; }
"left"                      { return LEFT; }
"right"                     { return RIGHT; }
"endfold"                   { return ENDFOLD; }
"and"                       { return AND; }
"or"                        { return OR; }
"not"                       { return NOT; }

"<="                        { return LESSEQUAL; }
">="                        { return GREATEREQUAL; }
"<>"                        { return NOTEQUAL; }
"<"                         { return LESS; }
">"                         { return GREATER; }
"="                         { return EQUAL; }

"+"                         { return '+'; }
"-"                         { return '-'; }
"*"                         { return '*'; }
"/"                         { return '/'; }
"%"                         { return '%'; }
"^"                         { return '^'; }

":"                         { return ':'; }
","                         { return ','; }
";"                         { return ';'; }
"("                         { return '('; }
")"                         { return ')'; }

{ID}                        { yylval.lexeme = strdup(yytext); return IDENTIFIER; }

[ \t\r\n]+                  { /* skip whitespace */ }
.                           appendError(LEXICAL, string("Invalid character"));

%%

int yywrap() {
    return 1;
}
