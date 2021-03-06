FROM shridh0r/python-ubuntu:3.7
MAINTAINER Shridhar <shridharpatil2792@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV LANGUAGE=C.UTF-8
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8


RUN apt-get install -y --no-install-suggests --no-install-recommends \
    git \
    nodejs \
    mysql-client \
    libssl-dev \
    wkhtmltopdf \
    curl \
    gcc \
    g++ \
    build-essential \
    sudo \
    postgresql-client

RUN apt-get install curl
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install yarn

# Add frappe user and setup sudo
RUN groupadd -g 1000 frappe \
  && useradd -ms /bin/bash -u 1000 -g 1000 -G sudo frappe \
  && printf '# Sudo rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/frappe


COPY start_up.sh /home/frappe/
RUN chown -R 1000:1000 /home/frappe

USER frappe
WORKDIR /home/frappe


ARG FRAPPE_PATH="https://github.com/frappe/frappe.git"
ARG FRAPPE_BRANCH="master"
ARG FRAPPE_PYTHON=python3
ARG FRAPPE="frappe-bench"
ARG DB_HOST="127.0.0.1"
ARG MYSQL_ROOT_PWD="root"
ARG DB_NAME="localsite"
ARG SITE_NAME="site1.local"
ARG BENCH_BRANCH=master
ARG BENCH_PATH=https://github.com/frappe/bench.git
ENV PATH="${PATH}:/home/frappe/.local/bin"

RUN sudo apt-get install -y npm

ARG CACHE
RUN /bin/sh ./start_up.sh build
#bench setup socketio
WORKDIR /home/frappe/frappe-bench
RUN bench setup socketio
RUN bench setup requirements

WORKDIR /home/frappe/frappe-bench
CMD ["/bin/sh"]
