// CMSC 430 Compiler Theory and Design
// Project 4
// Gracie Saxon
// April 29, 2025

// This file contains the template symbol table

#ifndef SYMBOLS_H
#define SYMBOLS_H

#include <map>
#include <string>

using namespace std;

template <typename T>
class Symbols
{
public:
    void insert(char* lexeme, T entry);
    bool find(char* lexeme, T& entry);
private:
    map<string, T> symbols;
};

template <typename T>
void Symbols<T>::insert(char* lexeme, T entry)
{
    string name(lexeme);
    symbols[name] = entry;
}

template <typename T>
bool Symbols<T>::find(char* lexeme, T& entry)
{
    string name(lexeme);
    typedef typename map<string, T>::iterator Iterator;
    Iterator iterator = symbols.find(name);
    bool found = iterator != symbols.end();
    if (found)
        entry = iterator->second;
    return found;
}

#endif