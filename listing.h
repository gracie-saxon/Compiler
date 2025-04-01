// CMSC 430 Compiler Theory and Design
// Project 1 
// Gracie Saxon
// March 24, 2025

// This file contains the function prototypes for the functions that produce
// the compilation listing

#include <string>
using namespace std;

enum ErrorCategories {LEXICAL, SYNTAX, GENERAL_SEMANTIC, DUPLICATE_IDENTIFIER,
    UNDECLARED};

void firstLine();
void nextLine();
int lastLine();
void appendError(ErrorCategories errorCategory, string message);

