// CMSC 430 Compiler Theory and Design
// Project 3
// values.cc

// This file contains the bodies of the evaluation functions

#include <string>
#include <vector>
#include <cmath>

using namespace std;

#include "values.h"

double evaluateReduction(const vector<double>& values, Operators operator_type, bool left)
{
    if (values.size() == 0)
        return 0;
    
    if (values.size() == 1)
        return values[0];
        
    double result = values[0];
    if (left)
        for (unsigned i = 1; i < values.size(); i++)
            result = evaluateArithmetic(result, operator_type, values[i]);
    else
    {
        result = values[values.size() - 1];
        for (int i = values.size() - 2; i >= 0; i--)
            result = evaluateArithmetic(values[i], operator_type, result);
    }
    return result;
}

double evaluateArithmetic(double left, Operators operator_type, double right)
{
    switch (operator_type)
    {
        case ADD: return left + right;
        case MULTIPLY: return left * right;
    }
    return 0;
}

double evaluateRelational(double left, Operators operator_type, double right)
{
    switch (operator_type)
    {
        case LESS: return left < right;
        case AND: return left && right;
    }
    return 0;
}
