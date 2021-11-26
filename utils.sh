#!/usr/bin/env bash

pretty_print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

# message, output_variable
read_var_if_not_defined () {
    echo "[ -v '$'$2 ]"
    if [ -v '$'$2 ]
    then
      echo 'read -p $2"?$1: "'
      read -p $2"?$1: "
      export $2
    fi
}

# message, output_variable
read_var_if_not_defined_sensitive () {
    if [ -v $2 ]
    then 
     read -sp $2"?$1  you are not going to see what you type):  "
     export $2
    fi
}
