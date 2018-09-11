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
RUN apt-get update && apt-get install -y bison flex unzip python automake
RUN ln -s /usr/bin/automake-1.15 /usr/bin/automake-1.14
RUN ln -s /usr/bin/aclocal-1.15 /usr/bin/aclocal-1.14
USER mallard
WORKDIR /home/mallard/Projects/os/src/3rdparty
RUN source ../env-os.sh && ./3rdparty.sh stage1
WORKDIR /home/mallard/Projects/os/src
RUN make ; exit 0
WORKDIR /home/mallard/Projects/os/src/3rdparty
RUN source ../env-os.sh && ./3rdparty.sh stage2
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y grub-pc qemu xorriso mtools
USER mallard
RUN rm /home/mallard/Projects/os/.git
ADD --chown=mallard:mallard ./.git/modules/os /home/mallard/Projects/os/.git
RUN sed -i '/worktree = /d' /home/mallard/Projects/os/.git/config
WORKDIR /home/mallard/Projects/os/src
RUN make
ADD --chown=mallard:mallard ./qemu-launch-opts.txt /home/mallard/Projects/os/src/qemu-launch-opts.txt
ADD ./enable-kvm.sh /home/mallard/enable-kvm.sh
USER root
RUN echo -e "btosdev\nbtosdev" | passwd mallard
RUN apt-get update && apt-get install -y openssh-server sudo kmod
ADD ./sshd_config /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
EXPOSE 22
EXPOSE 5902
EXPOSE 4444
VOLUME /home/mallard/Projects/os
