#!/bin/bash
if ! brew list --formula | grep  "rust"; then
    echo "Installimg rust dependency"
    brew install rust
else
    echo "rust is already installed. Proceeding..."
fi