#!/bin/bash
if ! brew list --formula | grep  "ripgrep"; then
    echo "Installimg ripgrep dependency"
    brew install ripgrep
else
    echo "ripgrep is already installed. Proceeding..."
fi