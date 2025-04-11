// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 2025

// values.cc - Evaluation logic for arithmetic, logical, relational, and fold expressions

#include <string>
#include <cmath>
#include <vector>
#include <limits>

using namespace std;

#include "values.h"
#include "listing.h"

double evaluateArithmetic(double left, Operators operator_, double right) {
    switch (operator_) {
        case ADD: return left + right;
        case SUBTRACT: return left - right;
        case MULTIPLY: return left * right;
        case DIVIDE: 
            if (right == 0) {
                appendError(GENERAL_SEMANTIC, "Division by zero");
                return NAN;
            }
            return left / right;
        case REMAINDER: 
            if (right == 0) {
                appendError(GENERAL_SEMANTIC, "Modulo by zero");
                return NAN;
            }
            return static_cast<int>(left) % static_cast<int>(right);
        case EXPONENT: return pow(left, right);
        default: return NAN;
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
        default: return NAN;
    }
}

double evaluateLogical(double left, Operators operator_, double right) {
    switch (operator_) {
        case AND: return left && right;
        case OR: return left || right;
        default: return NAN;
    }
}

double evaluateNegation(double value) {
    return -value;
}

double evaluateFold(Direction dir, Operators oper, vector<double>* values) {
    if (!values || values->empty()) return NAN;

    double result = dir == LEFT_DIR ? (*values)[0] : (*values)[values->size() - 1];
    if (values->size() == 1) return result;

    if (dir == LEFT_DIR) {
        for (size_t i = 1; i < values->size(); ++i)
            result = evaluateArithmetic(result, oper, (*values)[i]);
    } else {
        for (int i = values->size() - 2; i >= 0; --i)
            result = evaluateArithmetic((*values)[i], oper, result);
    }

    return result;
}
