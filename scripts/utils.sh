#!/bin/bash

function temp_folder(){
    # Use date instead of /dev/urandom since it's based on driver noise
    # and thus does not work in CI
    uuid="$(date | sed 's/[^0-9]//g')"
    temp_folder="temp_${uuid}"
    mkdir ${temp_folder}
    cd ${temp_folder}
}

function cleanup_folder(){
    folder="$(pwd)"
    cd ..
    rm -rf ${folder}
}
