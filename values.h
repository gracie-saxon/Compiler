// CMSC 430 Compiler Theory and Design
// Project 3
// values.h

// This file contains function definitions for the evaluation functions

typedef char* CharPtr;

enum Operators {ADD, MULTIPLY, AND, LESS};

double evaluateReduction(const vector<double>& values, Operators operator_type, bool left);
double evaluateArithmetic(double left, Operators operator_type, double right);
double evaluateRelational(double left, Operators operator_type, double right);
