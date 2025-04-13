// values.h
// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 13, 2025

// This file contains type definitions and the function
// definitions for the evaluation functions

#ifndef VALUES_H
#define VALUES_H

#include <vector>
using namespace std;

typedef char* CharPtr;

enum Operators {
    // Arithmetic operators
    ADD, SUBTRACT, MULTIPLY, DIVIDE, REMAINDER, EXPONENT, NEGATION,
    // Relational operators
    LESS, GREATER, EQUAL, LESS_EQUAL, GREATER_EQUAL, NOT_EQUAL,
    // Logical operators
    AND, OR, NOT,
    // Direction for fold (not actually an operator)
    LEFT, RIGHT
};

double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);

#endif
