FROM docker:stable-git@sha256:13acdeba79907d8d4af41e0d6a08e47dbbbb3f4c1316e91088f3e0730b810706

WORKDIR /home/scripts

RUN apk update &&\
    apk add --no-cache bash git tar gzip ca-certificates docker jq sed curl &&\
    TRIVY_RELEASE=$(curl --silent  "https://api.github.com/repos/aquasecurity/trivy/tags" | jq .[0].name | sed 's/"//g' ) &&\
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin $TRIVY_RELEASE &&\
    git clone https://github.com/dreamquark-ai/github-action-security-report /tmp/security-report &&\
    mv /tmp/security-report/scripts /home &&\
    rm -rf /tmp/security-report/scripts


