#!/usr/bin/env -S bash -e

print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# message, output_variable
read_var_if_not_defined () {
    if [ -z ${var+x} ]; then
      read -r -p "$1:" $2
      export $2
    fi
}

# message, output_variable
read_var_if_not_defined_sensitive () {
    if [ -z ${var+x} ]; then
      read -r -s -p "$1  (you are not going to see what you type):" $2
      export $2
    fi
}

