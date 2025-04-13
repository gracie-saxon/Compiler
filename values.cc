// values.cc
// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 13, 2025

// This file contains the bodies of the evaluation functions

#include <string>
#include <cmath>
#include <limits>

using namespace std;

#include "values.h"
#include "listing.h"

double evaluateArithmetic(double left, Operators operator_, double right) {
    double result;
    
    switch (operator_) {
        case ADD:
            result = left + right;
            break;
        case SUBTRACT:
            result = left - right;
            break;
        case MULTIPLY:
            result = left * right;
            break;
        case DIVIDE:
            if (right == 0) {
                appendError(GENERAL_SEMANTIC, "Division by zero");
                result = numeric_limits<double>::quiet_NaN();
            } else {
                result = left / right;
            }
            break;
        case REMAINDER:
            if (right == 0) {
                appendError(GENERAL_SEMANTIC, "Modulo by zero");
                result = numeric_limits<double>::quiet_NaN();
            } else {
                // Use fmod for floating point remainder
                result = fmod(left, right);
            }
            break;
        case EXPONENT:
            result = pow(left, right);
            break;
    }
    
    return result;
}

double evaluateRelational(double left, Operators operator_, double right) {
    double result;
    
    switch (operator_) {
        case LESS:
            result = left < right;
            break;
        case GREATER:
            result = left > right;
            break;
        case EQUAL:
            result = left == right;
            break;
        case LESS_EQUAL:
            result = left <= right;
            break;
        case GREATER_EQUAL:
            result = left >= right;
            break;
        case NOT_EQUAL:
            result = left != right;
            break;
    }
    
    return result;
}
