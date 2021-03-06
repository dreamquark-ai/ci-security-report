#!/bin/bash
FOLDER=$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)
. "${FOLDER}/utils.sh"


#https://docs.github.com/en/rest/reference/issues#list-issue-comments
function comment_exists() {
    repo=$1
    pr=$2
    topic=$3
    orga=$4
    
    resp=$(curl -s -H "Authorization: token $GITHUB_PAT" \
    https://api.github.com/repos/$orga/$repo/issues/$pr/comments)
    #Check resp is an empty array
    if [ $(echo $resp | jq length) == 0 ]; then
        echo ""
    else
        echo "$resp" | jq  '.[] | select(.body | test(".*- (.*?)'"$topic"'\\s+")) | .id'
    fi
}

#https://docs.github.com/en/rest/reference/issues#create-an-issue-comment
function add_comment() {
    repo=$1
    pr=$2
    orga=$3

    resp=$(curl --silent -H "Authorization: token ${GITHUB_PAT}"  \
    -X POST -d @body \
    https://api.github.com/repos/$orga/$repo/issues/$pr/comments)
    echo "https://api.github.com/repos/$orga/$repo/issues/$pr/comments"
}

#https://docs.github.com/en/rest/reference/issues#delete-an-issue-comment
function delete_comment() {
    repo=$1
    comment_id=$2
    
    curl \
    -X DELETE --silent\
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${GITHUB_PAT}" \
    https://api.github.com/repos/$orga/$repo/issues/comments/$comment_id
}

function comment_pr() {
    repo=$1
    pr=$2
    topic=$3
    orga=$4

    temp_folder
    # Check if comment already exists
    id_found=$(comment_exists $repo $pr $topic $orga)

    if [[ ! -z "$id_found" ]]
    then
        echo "Security report already exists: remove the previous one."
        delete_comment $repo $id_found $orga
    fi
    # Add new comment
    echo "{\"body\":  \"$(cat ../reports/security.md |  sed "s/\"/'/g" | sed 's/$/\\n/')\"}" > body
    add_comment $repo $pr $orga
    cleanup_folder
}
