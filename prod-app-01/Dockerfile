FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential network diagnostics tools, SSH server, and sudo
RUN apt-get update && apt-get install -y \
    openssh-server iproute2 iputils-ping traceroute net-tools dnsutils nano sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

# Create the 'student' user with password '123'
RUN useradd -m -s /bin/bash student && echo "student:123" | chpasswd
RUN echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Inject autograder logic and check shorthand aliases
COPY autograder.sh /usr/local/bin/autograder.sh
RUN chmod +x /usr/local/bin/autograder.sh
RUN echo 'alias check="sudo /usr/local/bin/autograder.sh"' >> /home/student/.bashrc

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]