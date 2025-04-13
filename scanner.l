/* CMSC 430 Compiler Theory and Design
   Project 3
   Gracie Saxon
   April 13, 2025 */

/* This file contains flex input file */

%{
#include <cstdio>
#include <string>
#include <vector>
#include <cstring>

using namespace std;

#include "values.h"
#include "listing.h"
#include "tokens.h"

%}

%option noyywrap
ws		[ \t\r]+
comment		"//".*\n
line_comment	"--".*\n
line		[\n]
id		[A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])?|[A-Za-z]([A-Za-z0-9])*([A-Za-z0-9]_[A-Za-z0-9])*
digit		[0-9]
dec		{digit}+
hex		"#"([0-9]|[A-Fa-f])+
real		{digit}*"."({digit}+)(([eE][+-]?{digit}+))?|{digit}+"."({digit}*)(([eE][+-]?{digit}+))?
char		'[^\\']'|'\\[bntrf]'
punc		[\(\),:;]
%%
{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine(); }
{line_comment}	{ ECHO; nextLine(); }
{line}		{ ECHO; nextLine(); }
"+"		{ ECHO; yylval.oper = ADD; return(ADDOP); }
"-"		{ ECHO; yylval.oper = SUBTRACT; return(ADDOP); }
"*"		{ ECHO; yylval.oper = MULTIPLY; return(MULOP); }
"/"		{ ECHO; yylval.oper = DIVIDE; return(MULOP); }
"%"		{ ECHO; yylval.oper = REMAINDER; return(REMOP); }
"^"		{ ECHO; yylval.oper = EXPONENT; return(EXPOP); }
"~"		{ ECHO; yylval.oper = NEGATION; return(NEGOP); }
"&"		{ ECHO; yylval.oper = AND; return(ANDOP); }
"|"		{ ECHO; yylval.oper = OR; return(OROP); }
"!"		{ ECHO; yylval.oper = NOT; return(NOTOP); }
"<"		{ ECHO; yylval.oper = LESS; return(RELOP); }
">"		{ ECHO; yylval.oper = GREATER; return(RELOP); }
"="		{ ECHO; yylval.oper = EQUAL; return(RELOP); }
"<="		{ ECHO; yylval.oper = LESS_EQUAL; return(RELOP); }
">="		{ ECHO; yylval.oper = GREATER_EQUAL; return(RELOP); }
"<>"		{ ECHO; yylval.oper = NOT_EQUAL; return(RELOP); }
"=>"		{ ECHO; return(ARROW); }
begin		{ ECHO; return(BEGIN_); }
case		{ ECHO; return(CASE); }
character	{ ECHO; return(CHARACTER); }
else		{ ECHO; return(ELSE); }
elsif		{ ECHO; return(ELSIF); }
end		{ ECHO; return(END); }
endfold		{ ECHO; return(ENDFOLD); }
endif		{ ECHO; return(ENDIF); }
endswitch	{ ECHO; return(ENDSWITCH); }
fold		{ ECHO; return(FOLD); }
function	{ ECHO; return(FUNCTION); }
if		{ ECHO; return(IF); }
integer		{ ECHO; return(INTEGER); }
is		{ ECHO; return(IS); }
left		{ ECHO; return(LEFT); }
list		{ ECHO; return(LIST); }
of		{ ECHO; return(OF); }
others		{ ECHO; return(OTHERS); }
real		{ ECHO; return(REAL); }
returns		{ ECHO; return(RETURNS); }
right		{ ECHO; return(RIGHT); }
switch		{ ECHO; return(SWITCH); }
then		{ ECHO; return(THEN); }
when		{ ECHO; return(WHEN); }
{id}		{ ECHO; yylval.iden = (CharPtr)malloc(yyleng + 1); 
			strcpy(yylval.iden, yytext); return(IDENTIFIER);}
{dec}		{ ECHO; yylval.value = atoi(yytext); return(INT_LITERAL); }
{hex}		{ ECHO; yylval.value = hexToInt(yytext); return(INT_LITERAL); }
{real}		{ ECHO; yylval.value = atof(yytext); return(REAL_LITERAL); }
{char}		{ ECHO; yylval.value = parseCharLiteral(yytext); return(CHAR_LITERAL); }
{punc}		{ ECHO; return(yytext[0]); }
.		{ ECHO; appendError(LEXICAL, yytext); }
%%
