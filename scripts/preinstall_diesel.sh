#!/bin/bash
if ! brew list --formula | grep  "rust"; then
    echo "Installimg rust dependency"
    brew install rust
else
    echo "rust is already installed. Proceeding..."
fi

if ! brew list --formula | grep  "cmake"; then
    echo "Installimg cmake dependency"
    brew install cmake
else
    echo "cmake is already installed. Proceeding..."
fi


