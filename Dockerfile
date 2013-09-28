FROM ubuntu

RUN	echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list
RUN	echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list
RUN apt-get update

#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

#Supervisord
RUN apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN apt-get install -y openssh-server && mkdir /var/run/sshd && echo 'root:root' |chpasswd

#Utilities
RUN apt-get install -y vim less ntp net-tools inetutils-ping curl git

RUN apt-get install -y python g++ make checkinstall

#Install Node.js
RUN mkdir ~/src && cd $_ && \
    wget -N http://nodejs.org/dist/node-latest.tar.gz && \
    tar xzvf node-latest.tar.gz && cd node-v* && \
    ./configure && \
    checkinstall #(remove the "v" in front of the version number in the dialog) && \
    dpkg -i node_*

#Install R 3+
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu precise/' > /etc/apt/sources.list.d/r.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN apt-get update
RUN apt-get install -y r-base

#Install Shiny
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN npm install -g shiny-server

# Create a system account to run Shiny apps
RUN useradd -r shiny
# Create a root directory for your website
RUN mkdir -p /var/shiny-server/www
# Create a directory for application logs
RUN mkdir -p /var/shiny-server/log

#Supervisor starts everything
ADD	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 3838