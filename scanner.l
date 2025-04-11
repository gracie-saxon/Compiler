/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 2025

   This file contains the Flex input for lexical analysis */

%{
#include <cstdio>
#include <string>
#include <queue>
#include <vector>
using namespace std;

// Type definitions needed before tokens.h
typedef char* CharPtr;
enum Operators {
    ADD, SUBTRACT, MULTIPLY, DIVIDE, REMAINDER, EXPONENT, NEGATE,
    LESS, LESSEQUAL, GREATER, GREATEREQUAL, EQUAL, NOTEQUAL,
    AND, OR, NOT
};

#include "listing.h"
#include "tokens.h"

int hexToInt(const char* text);
int decodeEscape(const char* text);
%}

%option noyywrap

ws              [ \t\r]+
comment         "//".*\n
line_comment    "--".*\n
line            [\n]
id              [A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])?
digit           [0-9]
dec             {digit}+
hex             \#[0-9A-Fa-f]+
real            {digit}*\.({digit}+)(([eE][+-]?{digit}+))?|{digit}+\.({digit}*)(([eE][+-]?{digit}+))?
char            '\\[bntrf\\"\']'|'[^\\']'
punc            [\(\),:;]

%%
{ws}            { ECHO; }
{comment}       { ECHO; nextLine(); }
{line_comment}  { ECHO; nextLine(); }
{line}          { ECHO; nextLine(); }

"+"            { ECHO; yylval.oper = ADD; return(ADDOP); }
"-"            { ECHO; yylval.oper = SUBTRACT; return(ADDOP); }
"*"            { ECHO; yylval.oper = MULTIPLY; return(MULOP); }
"/"            { ECHO; yylval.oper = DIVIDE; return(MULOP); }
"%"            { ECHO; yylval.oper = REMAINDER; return(REMOP); }
"^"            { ECHO; yylval.oper = EXPONENT; return(EXPOP); }
"~"            { ECHO; yylval.oper = NEGATE; return(NEGOP); }
"&"            { ECHO; yylval.oper = AND; return(ANDOP); }
"|"            { ECHO; yylval.oper = OR; return(OROP); }
"!"            { ECHO; yylval.oper = NOT; return(NOTOP); }

"="            { ECHO; yylval.oper = EQUAL; return(RELOP); }
"<>"           { ECHO; yylval.oper = NOTEQUAL; return(RELOP); }
"<"            { ECHO; yylval.oper = LESS; return(RELOP); }
"<="           { ECHO; yylval.oper = LESSEQUAL; return(RELOP); }
">"            { ECHO; yylval.oper = GREATER; return(RELOP); }
">="           { ECHO; yylval.oper = GREATEREQUAL; return(RELOP); }

"=>"           { ECHO; return(ARROW); }

begin           { ECHO; return(BEGIN_); }
case            { ECHO; return(CASE); }
character       { ECHO; return(CHARACTER); }
else            { ECHO; return(ELSE); }
elsif           { ECHO; return(ELSIF); }
end             { ECHO; return(END); }
endif           { ECHO; return(ENDIF); }
endswitch       { ECHO; return(ENDSWITCH); }
endfold         { ECHO; return(ENDFOLD); }
fold            { ECHO; return(FOLD); }
function        { ECHO; return(FUNCTION); }
if              { ECHO; return(IF); }
integer         { ECHO; return(INTEGER); }
is              { ECHO; return(IS); }
left            { ECHO; return(LEFT); }
list            { ECHO; return(LIST); }
of              { ECHO; return(OF); }
others          { ECHO; return(OTHERS); }
real            { ECHO; return(REAL); }
returns         { ECHO; return(RETURNS); }
right           { ECHO; return(RIGHT); }
switch          { ECHO; return(SWITCH); }
then            { ECHO; return(THEN); }
when            { ECHO; return(WHEN); }

{id}            { ECHO; yylval.iden = strdup(yytext); return(IDENTIFIER); }
{dec}           { ECHO; yylval.value = atoi(yytext); return(INT_LITERAL); }
{hex}           { ECHO; yylval.value = hexToInt(yytext+1); return(INT_LITERAL); }
{real}          { ECHO; yylval.value = atof(yytext); return(REAL_LITERAL); }
{char}          { ECHO; 
                  if (yytext[1] == '\\') 
                      yylval.value = decodeEscape(yytext); 
                  else 
                      yylval.value = yytext[1]; 
                  return(CHAR_LITERAL); 
                }
{punc}          { ECHO; return(yytext[0]); }
.               { ECHO; appendError(LEXICAL, yytext); }

%%

int hexToInt(const char* text) {
    int value = 0;
    sscanf(text, "%x", &value);
    return value;
}

int decodeEscape(const char* text) {
    if (text[1] != '\\') return text[1];
    switch (text[2]) {
        case 'n': return '\n';
        case 't': return '\t';
        case 'r': return '\r';
        case 'f': return '\f';
        case 'b': return '\b';
        case '\\': return '\\';
        case '"': return '"';
        case '\'': return '\'';
        default: return text[2];
    }
}
