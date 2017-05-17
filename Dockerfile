FROM python:3.6

RUN apt-get update && \
	apt-get -y install dbus python-dbus-dev python3-dbus zip

# RUN pip install -U setuptools

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
# RUN pip3 install -r /requirements.txt
