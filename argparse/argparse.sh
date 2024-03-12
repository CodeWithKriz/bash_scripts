#!/bin/bash

# script can run only in linux and aws emr/ec2 not in mac terminal

cli_args=("$@")
# cli_args=("--abc" "123" "--def" "456" "val1" "val2" "--flag1" "--query" "select * from db.table" "--path" "/path/to/file" "--flag2")
echo "${#cli_args[@]}"

function check_value {
    arg=("$@")
    return_code=0
    case $arg in 
    -z)
        return_value=''
        return_code=1
    ;;
    -*|--*)
        return_value=''
        return_code=2
    ;;
    *)
        return_value=$arg
    ;;
    esac
    echo $return_value
    return $return_code
}

function parse_args {
    arg=("$@")
    pos_arg=()
    while [[ "${#arg[@]}" -gt 0 ]]; do
        case ${arg[0]} in
            -*|--*)
                key="${arg[0]//-/}" 
                arguments[$key]=$(check_value "${arg[1]}")
                if [[ $? -eq 0 ]]; then
                    arg=("${arg[@]:1}")
                fi
                arg=("${arg[@]:1}")
            ;;
            *)
                pos_arg+="${arg[0]} "
                arg=("${arg[@]:1}")
            ;;
        esac
    done
    arguments['-posArg']=${pos_arg}
    return 0
}

declare -A arguments
parse_args "${cli_args[@]}"

echo '########## PARSED ARGUMENTS ##########'
for key in ${!arguments[@]}; do
    if [[ ${key} == '-posArg' ]]; then
        pos=("${arguments[$key]}")
        for value in $pos; do
            echo "POSITIONAL ARGUMENTS << $value"
        done
    else
        echo "$key << '${arguments[$key]}'"
    fi
done
