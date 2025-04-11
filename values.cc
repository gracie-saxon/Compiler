// CMSC 430 Compiler Theory and Design
// Project 3
// Gracie Saxon
// April 2025

// values.cc - Evaluation logic for arithmetic, logical, relational, and fold expressions

#include <cmath>
#include "values.h"

double evaluateArithmetic(double left, Operators operator_, double right) {
    switch (operator_) {
        case OP_ADD: return left + right;
        case OP_SUBTRACT: return left - right;
        case OP_MULTIPLY: return left * right;
        case OP_DIVIDE: return right != 0 ? left / right : 0;
        case OP_REMAINDER: return static_cast<int>(left) % static_cast<int>(right);
        case OP_EXPONENT: return pow(left, right);
        default: return 0;
    }
}

double evaluateRelational(double left, Operators operator_, double right) {
    switch (operator_) {
        case OP_LESS: return left < right;
        case OP_LESSEQUAL: return left <= right;
        case OP_GREATER: return left > right;
        case OP_GREATEREQUAL: return left >= right;
        case OP_EQUAL: return left == right;
        case OP_NOTEQUAL: return left != right;
        default: return 0;
    }
}

double evaluateLogical(double left, Operators operator_, double right) {
    switch (operator_) {
        case OP_AND: return (left != 0) && (right != 0);
        case OP_OR: return (left != 0) || (right != 0);
        default: return 0;
    }
}

double evaluateNegation(double value) {
    return -value;
}

double evaluateFold(Direction dir, Operators oper, vector<double>* values) {
    if (values->empty()) return 0;

    double result;
    if (dir == LEFT_DIR) {
        result = values->at(0);
        for (size_t i = 1; i < values->size(); ++i)
            result = evaluateArithmetic(result, oper, values->at(i));
    } else { // RIGHT_DIR
        result = values->at(values->size() - 1);
        for (int i = static_cast<int>(values->size()) - 2; i >= 0; --i)
            result = evaluateArithmetic(values->at(i), oper, result);
    }
    return result;
}
