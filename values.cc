// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 2025

// values.cc - Evaluation logic for arithmetic, logical, relational, and fold expressions

#include <string>
#include <cmath>
#include <vector>

using namespace std;

#include "values.h"
#include "listing.h"

double evaluateArithmetic(double left, Operators operator_, double right) {
    switch (operator_) {
        case ADD: return left + right;
        case SUBTRACT: return left - right;
        case MULTIPLY: return left * right;
        case DIVIDE: 
            if (right != 0) 
                return left / right; 
            else {
                appendError(GENERAL_SEMANTIC, "Division by zero");
                return NAN;
            }
        case REMAINDER: 
            if (right != 0) 
                return static_cast<int>(left) % static_cast<int>(right);
            else {
                appendError(GENERAL_SEMANTIC, "Modulo by zero");
                return NAN;
            }
        case EXPONENT: return pow(left, right);
        default: 
            appendError(GENERAL_SEMANTIC, "Invalid arithmetic operator");
            return NAN;
    }
}

double evaluateRelational(double left, Operators operator_, double right) {
    switch (operator_) {
        case LESS: return left < right;
        case LESSEQUAL: return left <= right;
        case GREATER: return left > right;
        case GREATEREQUAL: return left >= right;
        case EQUAL: return left == right;
        case NOTEQUAL: return left != right;
        default: 
            appendError(GENERAL_SEMANTIC, "Invalid relational operator");
            return NAN;
    }
}

double evaluateLogical(double left, Operators operator_, double right) {
    switch (operator_) {
        case AND: return left && right;
        case OR: return left || right;
        default: 
            appendError(GENERAL_SEMANTIC, "Invalid logical operator");
            return NAN;
    }
}

double evaluateNegation(double value) {
    return -value;
}

double evaluateFold(Direction dir, Operators oper, vector<double>* values) {
    if (!values || values->empty()) {
        appendError(GENERAL_SEMANTIC, "Empty list in fold operation");
        return NAN;
    }

    // Handle single element lists
    if (values->size() == 1) {
        return (*values)[0];
    }

    double result;
    
    if (dir == LEFT_DIR) {
        // Left fold: ((a op b) op c) op d...
        result = (*values)[0];
        for (size_t i = 1; i < values->size(); ++i) {
            result = evaluateArithmetic(result, oper, (*values)[i]);
            if (isnan(result)) {
                return NAN; // Error occurred in evaluation
            }
        }
    } else {
        // Right fold: a op (b op (c op d...))
        result = (*values)[values->size() - 1];
        for (int i = values->size() - 2; i >= 0; --i) {
            result = evaluateArithmetic((*values)[i], oper, result);
            if (isnan(result)) {
                return NAN; // Error occurred in evaluation
            }
        }
    }

    return result;
}
