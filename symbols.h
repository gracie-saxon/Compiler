// CMSC 430 Compiler Theory and Design
// Project 3
// symbols.h 

// This file contains the class definition for the symbol table
// used for variables

template <typename T>
class Symbols
{
public:
    Symbols() {}
    bool find(char* name, T& value) const;
    void insert(char* name, T value);
private:
    struct Symbol
    {
        char* name;
        T value;
    };
    vector<Symbol> symbols;
};

template <typename T>
bool Symbols<T>::find(char* name, T& value) const
{
    for (const auto& symbol : symbols)
        if (strcmp(symbol.name, name) == 0)
        {
            value = symbol.value;
            return true;
        }
    return false;
}

template <typename T>
void Symbols<T>::insert(char* name, T value)
{
    Symbol symbol;
    symbol.name = name;
    symbol.value = value;
    symbols.push_back(symbol);
}
