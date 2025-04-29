// CMSC 430 Compiler Theory and Design
// Project 4
// Gracie Saxon
// April 29, 2025

// This file contains type definitions and the function
// prototypes for the type checking functions

#ifndef TYPES_H
#define TYPES_H

#include <string>
#include <vector>

using namespace std;

typedef char* CharPtr;

enum Types {MISMATCH, INT_TYPE, CHAR_TYPE, REAL_TYPE, NONE};

void checkAssignment(Types lValue, Types rValue, string message);
Types checkWhen(Types true_, Types false_);
Types checkSwitch(Types case_, Types when, Types other);
Types checkCases(Types left, Types right);
Types checkArithmetic(Types left, Types right);
Types checkListElements(const vector<Types>& elements);
bool checkListType(Types listType, Types elementType);
bool checkListSubscript(Types subscript);
bool checkCharacterComparison(Types left, Types right);
bool checkRemainder(Types left, Types right);
Types checkIfStatement(Types thenBranch, Types elseBranch);
bool checkFoldList(Types listType);

#endif

