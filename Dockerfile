FROM debian:buster

# Setup correct environment variable
ENV HOME /root

# Change to working directory
WORKDIR /opt

# To avoid having a prompt on tzdata setup during installation
ENV DEBIAN_FRONTEND=noninteractive

RUN chmod 1777 /tmp

# Install dependancies
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	build-essential \
	ca-certificates \
	curl \
	dmsetup \
	git \
	iptables \
	libgcrypt20-dev \
	lxc \
	python3 \
	python3-pip \
	supervisor \
	tcl8.6 \
	vim \
	wget \
	zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ -o get_docker.sh && sh get_docker.sh

# Install the magic wrapper.
ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker

WORKDIR /opt

# Create virtualenv to link dependancies
RUN pip3 install virtualenv && virtualenv .

WORKDIR /opt/TangoService/Tango

# Add in requirements
COPY requirements.txt .

# Install python dependancies
RUN pip3 install -r requirements.txt

# Move all code into Tango directory

COPY . .
RUN mkdir -p volumes

RUN mkdir -p /var/log/docker /var/log/supervisor

# Move custom config file to proper location
RUN cp /opt/TangoService/Tango/deployment/config/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 3000

# Reload new config scripts
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
