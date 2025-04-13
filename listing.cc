// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 13, 2025

// This file contains the bodies of the functions that produces the 
// compilation listing

#include <cstdio>
#include <string>
#include <queue>
using namespace std;
#include "listing.h"

static int lineNumber;
static queue<string> errorQueue;
static int lexicalErrors = 0;
static int syntaxErrors = 0;
static int semanticErrors = 0;

static void displayErrors();

void firstLine()
{
    lineNumber = 1;
    printf("\n%4d  ", lineNumber);
}

void nextLine()
{
    displayErrors();
    lineNumber++;
    printf("%4d  ", lineNumber);
}

int lastLine()
{
    printf("\r");
    displayErrors();
    printf("     \n");
    
    int totalErrors = lexicalErrors + syntaxErrors + semanticErrors;
    
    if (totalErrors > 0) {
        if (lexicalErrors > 0)
            printf("Lexical Errors %d\n", lexicalErrors);
        if (syntaxErrors > 0)
            printf("Syntax Errors %d\n", syntaxErrors);
        if (semanticErrors > 0)
            printf("Semantic Errors %d\n", semanticErrors);
    } else {
        printf("Compiled Successfully\n");
    }
    
    return totalErrors;
}
    
void appendError(ErrorCategories errorCategory, string message)
{
    string messages[] = { "Lexical Error, Invalid Character ", "Syntax Error, ",
        "Semantic Error, ", "Semantic Error, Duplicate ",
        "Semantic Error, Undeclared " };
    
    string errorMessage = messages[errorCategory] + message;
    errorQueue.push(errorMessage);
    
    if (errorCategory == LEXICAL)
        lexicalErrors++;
    else if (errorCategory == SYNTAX)
        syntaxErrors++;
    else
        semanticErrors++; 
}

void displayErrors()
{
    while (!errorQueue.empty()) {
        printf("%s\n", errorQueue.front().c_str());
        errorQueue.pop();
    }
}
