#!/bin/bash

set -e
FOLDER=$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)
. "${FOLDER}/../utils/utils.sh"


function generate_markdown() {
    report_folder=$1
    target=$2
    img=$3
    base_tag=$4
    new_tag=$5
    subject=$6

    template="$FOLDER/template.md"
    temp_folder

    old=$(cat $report_folder/old.json | jq length)
    new=$(cat $report_folder/new.json | jq length)

    echo "Beginning markdown generation"
    img=$(echo $img | sed -s "s/\//-/g")

    printf "# 🛡️ Security scan 🕵🚔🔫 - $subject \n\n" > security.md
    printf "You have $new security failures and $old have been removed from the $base_tag version of the image $img. \n\n" >> security.md
    printf "## New security failures \n\n" >> security.md
    # Generate table with the new vulnerabilities
    printf "\n|   Vulnerability  |   Package |   Package Version |   Severity |\n |---    |:-:    |:-:    |:-: |\n" >> security.md
    cat "${report_folder}/old.json" | jq -r '.[] | [.VulnerabilityID, .PkgName, .InstalledVersion, .Severity] | join(" | ")' | sed -E  "s/([^ ]*)(.*)/[\1](https:\/\/nvd.nist.gov\/vuln\/detail\/\1)\2/" | sed 's/$/ |a /'  >> security.md

    
    printf "\n ## Removed security failures \n\n" >> security.md
    printf "\n|  Vulnerability  | Package | Package Version | Severity |\n |---    |:-:    |:-:    |:-:  |\n" >> security.md
    cat "$report_folder/new.json" | jq -r '.[] | [.VulnerabilityID, .PkgName, .InstalledVersion, .Severity] | join(" | ")' | sed -E  "s/([^ ]*)(.*)/[\1](https:\/\/nvd.nist.gov\/vuln\/detail\/\1)\2/" | sed 's/$/ |a /'  >> security.md

    mv security.md $target
    cleanup_folder
}


