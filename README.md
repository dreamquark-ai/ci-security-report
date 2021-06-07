# Dreamquark security report action

This action is meant for generating diffrential security reports based on [trivy](https://github.com/aquasecurity/trivy) to be published as a comment of a pull request. 

From a base image used as reference, it underlies the new security failures and the one that have been removed after changes in your source code. 


## Example of usage

Before calling the action make sure to get the images (the base and the new one) in the pipeline either by pulling or building them.  

```name: Example of workflow for security report

on:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-20.04
    steps:
    - uses: actions/checkout@master

    - name: Pull the base image
      run: docker pull python:3.10-rc-slim

    - name: Build the new image
      run: docker build -t python:security-test -f example/Dockerfile .

    - name: "Security reports"
      uses: dreamquark-ai/github-action-security-report@main
      env:
        GITHUB_PAT: ${{secrets.SECURITY_REPORT_ACTION_EXAMPLE_PAT}}
      with:
        image: 'python'
        base-tag: 3.10-rc-slim
        new-tag: 'security-test'
        orga: 'dreamquark-ai'
        repo: 'github-action-security-report'
        pr-nb: ${{ github.event.number }}
        topic: 'example'
```

## Inputs

|   Name  | Type | Default | Required | Description |
|---    |:-:    |:-: |:-: |:-: |
image | `string` |  | `true` | The image on which differential reports must be performed |a
base-tag | `string` | `latest` | `true` | The tag of the base image used as reference |a
new-tag | `string` | `security-test` | `true` | The tag of the new image used to seek out new and removed vulnerabilities |a
repo | `string` |  | `true` |  Repository on which the action is triggered |a
pr-nb | `string` |  | `true` | PR number on which to comment with the security report |a
topic | `string` | `image` | `true` | The title of the report: used to identify the security report |a



