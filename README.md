# Dreamquark CI security report

This action is meant for generating differential security reports based on [Trivy](https://github.com/aquasecurity/trivy) to be published as a comment of a pull request. 

From a base image used as reference, it underlies the new security vulnerabilities and the one that have been removed after changes in your source code. 


## Example of usage

>### Prerequesites

Before calling the action or the orbs, you need to make sure, in the job or in the workflow that:
  * An environment variable is set in your GitHub secrets or in your CircleCI context valued with
  a valid Github PAT with rights on repositories. The scripts expect to get an environment variable named
  `GITHUB_PAT`.

  * The images (the base and the new one) exist in the pipeline either by pulling or building them.  

>### Use of the Github Action

```name: Example of workflow for security report

on:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-20.04
    steps:
    - uses: actions/checkout@master

    - name: Pull the base image
      run: docker pull python:3.8-buster

    - name: Build the new image
      run: docker build -t python:security-test -f example/Dockerfile .

    - name: "Security reports"
      uses: dreamquark-ai/ci-security-report@main
      env:
        GITHUB_PAT: ${{secrets.PAT_SECURITY_REPORT_ACTION_EXAMPLE}}
      with:
        image: 'python'
        base-tag: '3.8-buster'
        new-tag: 'security-test'
        orga: 'PaulBarrie'
        repo: 'ci-security-report-example'
        pr-nb: ${{ github.event.number }}
        topic: 'github-example'
```

>### Use of the CircleCI Orb

```version: 2.1

orbs:
  security-report: dreamquark-ai/ci-security-report@1.0.0

executors:
  security-report: dreamquark-ai/ci-security-report@1.0.0

jobs:
  security-report-example:
    executor: security-report/default
    working_directory: /root/ci-example
    steps:
      - checkout
      - setup_remote_docker:
          docker_layer_caching: false
          version: 20.10.2
      - run:
          name: "Build & pull the images for security report"
          command: |
            docker pull python:3.8-buster
            docker build -t python:security-test -f example/Dockerfile .
            
      - security-report/security-report:
          image: 'python'
          base-tag: '3.8-buster'
          new-tag: 'security-test'
          orga: 'PaulBarrie'
          repo: 'ci-security-report-example'
          topic: 'circleci-example'

workflows:
  CI-security-test:
    jobs:
      - security-report-example:
          context: security-report-example
```
## Inputs

|   Name  | Type | Default | Required | Description |
|---    |:-:    |:-: |:-: |:-: |
image | `string` |  | `true` | The image on which differential reports must be performed |a
base-tag | `string` | `latest` | `true` | The tag of the base image used as reference |a
new-tag | `string` | `security-test` | `true` | The tag of the new image used to seek out new and removed vulnerabilities |a
repo | `string` | `dreamquark-ai` | `true` |  Your GitHub organization name |a
repo | `string` |  | `true` |  Repository on which the action is triggered |a
pr-nb | `string` |  | `true` | PR number on which to comment with the security report |a
topic | `string` | `image` | `true` | The title of the report: used to identify the security report |a


## Code Description

As you may notice in the GitHub action and orb's command definition, the last step consists in executing a `main.sh` script. This script calls three others:

* A `parse-json.sh` script which will find the differences between the two previously generated Trivy report and will generate two json array files with all the vulnerabilities and their related details in the subfolder report:
  * A `old.json` file that will contain a list of all the vulnerabilities that have been withdrawn (i.e: the one which are in the report of the base image but not in the report of the new image).
  
  * A `new.json` file that will contain a list of all the vulnerabilities that have been added (i.e: the one which are not in the report of the base image but are in the report of the new image).

* A `md-template.sh` script which will, from the two previously generated json files, generate a markdown summary with two tables containing the new and the removed vulnerabilities.
* A `comment-pr.sh` script that will comment the specified pull request with the previously generated markdown report. Basically:
  * It looks like if a report already exists by parsing all the comments and checking if one matches with the specified topic.
  * If so, it deletes the previous comment (the previous security report in the pull request).
  * And to finish it adds a comment in the pull request using the markdown report.