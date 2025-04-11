// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 2025

// values.h - Type definitions and function declarations for evaluations

#ifndef VALUES_H
#define VALUES_H

#include <vector>
using namespace std;

typedef char* CharPtr;

// Operator types
enum Operators {
    OP_ADD, OP_SUBTRACT, OP_MULTIPLY, OP_DIVIDE, OP_REMAINDER, OP_EXPONENT, OP_NEGATE,
    OP_LESS, OP_LESSEQUAL, OP_GREATER, OP_GREATEREQUAL, OP_EQUAL, OP_NOTEQUAL,
    OP_AND, OP_OR, OP_NOT
};

enum Direction { LEFT_DIR, RIGHT_DIR };

// Function declarations
double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);
double evaluateLogical(double left, Operators operator_, double right);
double evaluateNegation(double value);
double evaluateFold(Direction dir, Operators oper, vector<double>* values);

#endif
