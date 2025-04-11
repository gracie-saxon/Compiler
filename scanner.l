/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 2025

   This file contains the Flex input for lexical analysis */

%{
#include "listing.h"
#include "parser.tab.h"
#include <string>
#include <vector>
#include "values.h"

using namespace std;
%}

///////////////////////////////////////////////////
//    Patterns / Definitions
///////////////////////////////////////////////////
DIGIT       [0-9]
HEXDIGIT    [0-9a-fA-F]
ID          [a-zA-Z][a-zA-Z0-9]*

///////////////////////////////////////////////////
//    Rules
///////////////////////////////////////////////////
%%
///////////////////////////////////////////////////////////////////////////
// Integer literals
///////////////////////////////////////////////////////////////////////////
{DIGIT}+                 { yylval.lexeme = strdup(yytext); return INT_LITERAL; }
0[xX]{HEXDIGIT}+         { yylval.lexeme = strdup(yytext); return INT_LITERAL; }

///////////////////////////////////////////////////////////////////////////
// Character literals (escape sequences + single char)
///////////////////////////////////////////////////////////////////////////
'\\n'                    { yylval.lexeme = strdup("\n");  return CHAR_LITERAL; }
'\\t'                    { yylval.lexeme = strdup("\t");  return CHAR_LITERAL; }
'\\''                    { yylval.lexeme = strdup("'");   return CHAR_LITERAL; }
'\\\\'                   { yylval.lexeme = strdup("\\");  return CHAR_LITERAL; }
/'[^\\\\']'/             { 
                           // Single non-escape char literal
                           // e.g. 'a' or 'Z'
                           // We store only the inside char
                           char* val = new char[2];
                           val[0] = yytext[1];
                           val[1] = '\0';
                           yylval.lexeme = val;
                           return CHAR_LITERAL; 
                         }

///////////////////////////////////////////////////////////////////////////
// Keywords that match your parser tokens
///////////////////////////////////////////////////////////////////////////
"function"              { return FUNCTION; }
"returns"               { return RETURNS; }
"begin"                 { return BEGIN_; }
"end"                   { return END; }
"if"                    { return IF; }
"then"                  { return THEN; }
"else"                  { return ELSE; }
"endif"                 { return ENDIF; }
"fold"                  { return FOLD; }
"left"                  { return LEFT; }
"right"                 { return RIGHT; }
"endfold"               { return ENDFOLD; }
"and"                   { return AND; }
"or"                    { return OR; }
"not"                   { return NOT; }

///////////////////////////////////////////////////////////////////////////
// Relational operators
///////////////////////////////////////////////////////////////////////////
"<="                    { return LESSEQUAL; }
">="                    { return GREATEREQUAL; }
"<>|!="                 { return NOTEQUAL; }   // Optionally allow '<>' or '!='
"<"                     { return LESS; }
">"                     { return GREATER; }
"="                     { return EQUAL; }

///////////////////////////////////////////////////////////////////////////
// Arithmetic operators
///////////////////////////////////////////////////////////////////////////
"\\+"                   { return '+'; }
"-"                     { return '-'; }
"\\*"                   { return '*'; }
"/"                     { return '/'; }
"%"                     { return '%'; }
"\\^"                   { return '^'; }

///////////////////////////////////////////////////////////////////////////
// Other punctuation
///////////////////////////////////////////////////////////////////////////
":"                     { return ':'; }
","                     { return ','; }
";"                     { return ';'; }
"\\("                   { return '('; }
"\\)"                   { return ')'; }

///////////////////////////////////////////////////////////////////////////
// Identifiers
///////////////////////////////////////////////////////////////////////////
{ID}                    { yylval.lexeme = strdup(yytext); return IDENTIFIER; }

///////////////////////////////////////////////////////////////////////////
// Whitespace (ignored)
///////////////////////////////////////////////////////////////////////////
[ \t\r\n]+              { /* skip whitespace */ }

///////////////////////////////////////////////////////////////////////////
// Fallback for unknown tokens - helps debug
///////////////////////////////////////////////////////////////////////////
.                       { 
                          printf("Unknown token: %s\n", yytext);
                          appendError(LEXICAL, string("Invalid character: ") + yytext);
                        }

%%
///////////////////////////////////////////////////
//    Wrap-Up
///////////////////////////////////////////////////
int yywrap() {
    return 1;
}
