#!/bin/bash

set -e
FOLDER=$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)
. "${FOLDER}/parse-json.sh"
. "${FOLDER}/md-template.sh"
. "${FOLDER}/comment-pr.sh"


base_report="$FOLDER/reports/report-base.json"
new_report="$FOLDER/reports/report-new.json"
target="$FOLDER/reports/security.md"
report_folder="$FOLDER/reports"


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -i|--image)
    image="$2"
    shift 
    shift 
    ;;
    -bt|--base-tag)
    base_tag="$2"
    shift 
    shift 
    ;;
    -nt|--new-tag)
    new_tag="$2"
    shift 
    shift 
    ;;
    -r|--repo)
    repo="$2"
    shift 
    shift 
    ;;
    -pr|--pull-request)
    pr="$2"
    shift 
    shift 
    ;;
    -t|--topic)
    topic="$2"
    shift 
    shift 
    ;;
    *)    
    POSITIONAL+=("$1")
    shift 
    ;;
esac
done


echo "Compare the differences between $base_report and $new_report."
get_differences $base_report $new_report $report_folder
echo "Generate the report for $image:$base_tag->$new_tag."
generate_markdown $report_folder $report_folder $image $base_tag $new_tag $topic
echo "Publish the report as a comment of the PR #$pr to $repo related to $topic"
comment_pr $repo $pr $topic
