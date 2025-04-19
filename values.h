// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 19, 2025

// This file contains type definitions and the function
// definitions for the evaluation functions

#ifndef VALUES_H
#define VALUES_H

typedef char* CharPtr;

enum Operators {
    ADD, SUBTRACT, MULTIPLY, DIVIDE, REMAINDER, EXPONENT, NEGATION,
    LESS, GREATER, EQUAL, LESS_EQUAL, GREATER_EQUAL, NOT_EQUAL,
    AND, OR, NOT,
    LEFT, RIGHT
};

double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);
int hexToInt(const char* hexStr);
char parseCharLiteral(const char* literal);

#endif
