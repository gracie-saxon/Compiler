// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 19, 2025

// This file contains the bodies of the evaluation functions

#include <string>
#include <cmath>
#include <limits>
#include <cstdlib>

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
        default:
            appendError(GENERAL_SEMANTIC, "Unknown arithmetic operator");
            result = numeric_limits<double>::quiet_NaN();
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
        default:
            appendError(GENERAL_SEMANTIC, "Unknown relational operator");
            result = numeric_limits<double>::quiet_NaN();
    }
    
    return result;
}

// Convert a hexadecimal string to an integer
int hexToInt(const char* hexStr) {
    // Skip the '#' prefix
    return strtol(hexStr + 1, NULL, 16);
}

// Parse a character literal, handling escape characters
char parseCharLiteral(const char* literal) {
    if (literal[1] != '\\')
        return literal[1];
    
    // Handle escape characters
    switch(literal[2]) {
        case 'n': return '\n';
        case 't': return '\t';
        case 'r': return '\r';
        case 'f': return '\f';
        case 'b': return '\b';
        default: return literal[2];
    }
}
