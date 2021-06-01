FROM python:3.10-rc-slim

USER root
# Remove package with vulnerabilities and add one with vulnerabilities
RUN rm -rf /usr/share/doc/libc-bin /usr/share/libc-bin &&\
    apt-get update -y &&\
    apt-get install -y openssh-client
