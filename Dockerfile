FROM debian:stretch-slim
RUN apt-get update && apt-get install -y build-essential git bash wget autoconf2.64 automake1.11
RUN useradd --create-home --shell /bin/bash mallard
RUN adduser mallard sudo
USER mallard
RUN mkdir -p /home/mallard/Projects
ADD --chown=mallard:mallard ./os /home/mallard/Projects/os
WORKDIR /home/mallard/Projects/os/src
SHELL ["/bin/bash", "-c"]
RUN source env-os.sh && ./setup-toolchain.sh download
USER root
RUN apt-get update && apt-get install -y libgmp-dev libmpfr-dev libmpc-dev
USER mallard
RUN source env-os.sh && ./setup-toolchain.sh buildonly
EXPOSE 5901
