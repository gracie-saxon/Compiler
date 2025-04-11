// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 2025

// values.h - Type definitions and function declarations for evaluations

#ifndef VALUES_H
#define VALUES_H

#include <vector>
#include <cmath>

typedef char* CharPtr;

// Operator types
enum Operators {
    ADD, SUBTRACT, MULTIPLY, DIVIDE, REMAINDER, EXPONENT, NEGATE,
    LESS, LESSEQUAL, GREATER, GREATEREQUAL, EQUAL, NOTEQUAL,
    AND, OR, NOT
};

enum Direction { LEFT_DIR, RIGHT_DIR };

double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);
double evaluateLogical(double left, Operators operator_, double right);
double evaluateNegation(double value);
double evaluateFold(Direction dir, Operators oper, std::vector<double>* values);

#endif
