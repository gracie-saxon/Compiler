// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 13, 2025

// This file contains type definitions and the function
// definitions for the evaluation functions

#ifndef VALUES_H
#define VALUES_H

typedef char* CharPtr;

// Define all operators needed by scanner and parser
enum Operators {
    // Arithmetic operators
    ADD, SUBTRACT, MULTIPLY, DIVIDE, REMAINDER, EXPONENT, NEGATION,
    // Relational operators
    LESS, GREATER, EQUAL, LESS_EQUAL, GREATER_EQUAL, NOT_EQUAL,
    // Logical operators
    AND, OR, NOT,
    // Direction indicators (not actual operators)
    LEFT, RIGHT
};

// Function prototypes
double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);
int hexToInt(const char* hexStr);
char parseCharLiteral(const char* literal);

#endif
