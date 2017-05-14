FROM python:3.6

RUN apt-get update && \
	apt-get -y install zip

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
