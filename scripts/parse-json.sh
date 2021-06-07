#!/bin/bash

set -e
FOLDER=$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)
. "${FOLDER}/utils.sh"


function get_differences() {
    base_report=$1
    new_report=$2
    target_folder=$3

    mkdir -p $target_folder
    temp_folder

    cat $base_report | jq -r '.[].Vulnerabilities[]? | [.VulnerabilityID?, .PkgName?, .InstalledVersion?] | join(",")' | sort > tmp-base
    cat $new_report | jq -r '.[].Vulnerabilities[]? | [.VulnerabilityID?, .PkgName?, .InstalledVersion?] | join(",")' | sort > tmp-new

    # Get added and removed the vulnerabilities
    echo "Get the added and removed vulnerabilities"
    comm -13 tmp-base tmp-new > tmp-added
    comm -23 tmp-base tmp-new > tmp-rm

    # Get a proper json with all the vulnerabilities
    echo "Get proper json with all the vulnerabilities"
    # Get the new vulnerabilities
    echo "[" > new.json
    cat tmp-added | sed -s -e 's/^\([^,]*\),\([^,]*\),\(.*\)$/ cat '$(echo $new_report | sed -s "s|/|\\\/|g" )' |  jq \x27 .[].Vulnerabilities[]? |  select(.VulnerabilityID =="\1" and .PkgName =="\2" and .InstalledVersion=="\3") \x27/' | sh | head -c-1 | sed -z 's/}\n{/},\n{/g'  >> new.json
    echo "]" >> new.json
    # Get the removed vulnerabilities
    echo "[" > old.json
    cat tmp-rm |  sed -s -e 's/^\([^,]*\),\([^,]*\),\(.*\)$/ cat '$(echo $base_report | sed -s "s|/|\\\/|g" )' |  jq \x27 .[].Vulnerabilities[]? |  select(.VulnerabilityID =="\1" and .PkgName =="\2" and .InstalledVersion=="\3") \x27/' | sh | head -c-1 | sed -z 's/}\n{/},\n{/g' >> old.json
    echo "]" >> old.json

    mv new.json $target_folder    
    mv old.json $target_folder

    cleanup_folder
}

