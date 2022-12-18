#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "" >> ~/.bashrc
echo "# Custom env setup and aliases" >> ~/.bashrc
echo "# For more info: https://github.com/iholder101/aliases_env_setup" >> ~/.bashrc
echo "source ${SCRIPT_DIR}/env_setup.sh" >> ~/.bashrc
echo "source ${SCRIPT_DIR}/aliases.sh" >> ~/.bashrc
echo "" >> ~/.bashrc

