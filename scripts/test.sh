#!/bin/bash

resp=$(curl -s -H "Authorization: token $GITHUB_PAT" https://api.github.com/repos/dreamquark-ai/docker-images/issues/54/comments)
#Check resp is an empty array
echo "$resp"
if [ $(echo $resp | jq length) == 0 ]; then
    echo "dfgb"
else
    echo $resp | jq  '.[] | select(.body | test(".*- (.*?)'"$topic"'\\s+")) | .id'
fi