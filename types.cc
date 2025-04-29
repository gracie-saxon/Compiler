// CMSC 430 Compiler Theory and Design
// Project 4
// Gracie Saxon
// April 29, 2025

// This file contains the bodies of the type checking functions

#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"

void checkAssignment(Types lValue, Types rValue, string message) {
    if (lValue != MISMATCH && rValue != MISMATCH) {
        if (lValue != rValue) {
            // Allow widening (INT_TYPE to REAL_TYPE)
            if (lValue == REAL_TYPE && rValue == INT_TYPE) {
                return; // This is allowed - widening
            }
            // For non-narrowing type mismatches
            if (!(lValue == INT_TYPE && rValue == REAL_TYPE)) {
                appendError(GENERAL_SEMANTIC, "Type Mismatch on " + message);
            }
            // Narrowing errors are reported in the parser
        }
    }
}

Types checkWhen(Types true_, Types false_) {
    if (true_ == MISMATCH || false_ == MISMATCH)
        return MISMATCH;
    if (true_ != false_)
        appendError(GENERAL_SEMANTIC, "When Types Mismatch");
    return true_;
}

Types checkSwitch(Types case_, Types when, Types other) {
    if (case_ != INT_TYPE)
        appendError(GENERAL_SEMANTIC, "Switch Expression Not Integer");
    return checkCases(when, other);
}

Types checkCases(Types left, Types right) {
    if (left == MISMATCH || right == MISMATCH)
        return MISMATCH;
    if (left == NONE || left == right)
        return right;
    appendError(GENERAL_SEMANTIC, "Case Types Mismatch");
    return MISMATCH;
}

Types checkArithmetic(Types left, Types right) {
    if (left == MISMATCH || right == MISMATCH)
        return MISMATCH;
    
    // Both operands must be numeric types
    if ((left == INT_TYPE || left == REAL_TYPE) && 
        (right == INT_TYPE || right == REAL_TYPE)) {
        
        // If either is REAL_TYPE, result is REAL_TYPE (coercion)
        if (left == REAL_TYPE || right == REAL_TYPE)
            return REAL_TYPE;
        
        // Both are INT_TYPE
        return INT_TYPE;
    }
    
    appendError(GENERAL_SEMANTIC, "Arithmetic Operator Requires Numeric Types");
    return MISMATCH;
}

Types checkListElements(const vector<Types>& elements) {
    if (elements.empty())
        return NONE;
    
    Types firstType = elements[0];
    
    for (size_t i = 1; i < elements.size(); i++) {
        if (elements[i] != firstType) {
            appendError(GENERAL_SEMANTIC, "List Element Types Do Not Match");
            return MISMATCH;
        }
    }
    
    return firstType;
}

bool checkListType(Types listType, Types elementType) {
    if (listType != elementType) {
        appendError(GENERAL_SEMANTIC, "List Type Does Not Match Element Types");
        return false;
    }
    return true;
}

bool checkListSubscript(Types subscript) {
    if (subscript != INT_TYPE) {
        appendError(GENERAL_SEMANTIC, "List Subscript Must Be Integer");
        return false;
    }
    return true;
}

bool checkCharacterComparison(Types left, Types right) {
    // Can compare char to char
    if (left == CHAR_TYPE && right == CHAR_TYPE)
        return true;
    
    // Cannot compare char to numeric
    if ((left == CHAR_TYPE && (right == INT_TYPE || right == REAL_TYPE)) ||
        (right == CHAR_TYPE && (left == INT_TYPE || left == REAL_TYPE))) {
        appendError(GENERAL_SEMANTIC, "Character Literals Cannot be Compared to Numeric Expressions");
        return false;
    }
    
    return true;
}

bool checkRemainder(Types left, Types right) {
    if (left != INT_TYPE || right != INT_TYPE) {
        appendError(GENERAL_SEMANTIC, "Remainder Operator Requires Integer Operands");
        return false;
    }
    return true;
}

Types checkIfStatement(Types thenBranch, Types elseBranch) {
    if (thenBranch == MISMATCH || elseBranch == MISMATCH)
        return MISMATCH;
    
    // None is like a placeholder for no else clause
    if (elseBranch == NONE)
        return thenBranch;
        
    if (thenBranch != elseBranch) {
        appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
        return MISMATCH;
    }
    
    return thenBranch;
}

bool checkFoldList(Types listType) {
    if (listType != INT_TYPE && listType != REAL_TYPE) {
        appendError(GENERAL_SEMANTIC, "Fold Requires A Numeric List");
        return false;
    }
    return true;
}
