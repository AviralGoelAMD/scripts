#!/bin/bash

# Upgrade optree package
python3 -m pip install --upgrade 'optree>=0.13.0'

# Set PYTHONPATH to the pytorch directory
export PYTHONPATH=$(pwd)/pytorch

# Run the specified test and save output
pytest pytorch/test/inductor/test_ck_backend.py -k conv | tee conv_output.txt

# Print success message in green
echo -e "\e[32mTest execution completed. Output saved in conv_output.txt.\e[0m"

