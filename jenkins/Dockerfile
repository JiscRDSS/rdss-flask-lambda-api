FROM jenkins:2.46.2-alpine

USER root

RUN apk add --no-cache \
    make \
    postgresql \
    python3

RUN apk add --no-cache py-pip

RUN pip install virtualenv

USER jenkins
