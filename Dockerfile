FROM debian:stretch-slim
RUN apt-get update && apt-get install -y build-essential git bash wget autoconf2.64 automake1.11
RUN useradd --create-home --shell /bin/bash mallard
RUN adduser mallard sudo
USER mallard
RUN mkdir -p /home/mallard/Projects
ADD --chown=mallard:mallard ./os /home/mallard/Projects/os
WORKDIR /home/mallard/Projects/os/src
USER root
RUN apt-get update && apt-get install -y libgmp-dev libmpfr-dev libmpc-dev gperf
SHELL ["/bin/bash", "-c"]
USER mallard
RUN source env-os.sh && ./setup-toolchain.sh download
RUN source env-os.sh && ./setup-toolchain.sh buildonly stage1
RUN source env-os.sh && ./setup-toolchain.sh buildonly stage2
RUN source env-os.sh && ./setup-toolchain.sh buildonly stage3
RUN source env-os.sh && ./setup-toolchain.sh buildonly stage4
RUN make ; exit 0
USER root
RUN apt-get update && apt-get install -y bison flex unzip mtools
USER mallard
WORKDIR /home/mallard/Projects/os/src/3rdparty
RUN ./3rdparty.sh stage1
WORKDIR /home/mallard/Projects/os/src
RUN make ; exit 0
WORKDIR /home/mallard/Projects/os/src/3rdparty
RUN ./3rdparty.sh stage2
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y grub-pc qemu xorriso
USER mallard
WORKDIR /home/mallard/Projects/os/src
RUN make
EXPOSE 22
EXPOSE 5901
