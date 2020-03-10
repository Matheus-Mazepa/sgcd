# Base Image
FROM ruby:2.6.5

# Encoding
ENV LANG C.UTF-8


# -q, --quiet
#    Quiet. Produces output suitable for logging, omitting progress indicators.
#    More q's will produce more quiet up to a maximum of two. You can also use
#    -q=# to set the quiet level, overriding the configuration file. Note that
#    quiet level 2 implies -y, you should never use -qq without a no-action
#    modifier such as -d, --print-uris or -s as APT may decided to do something
#    you did not expect.
#
#    build-essential is a package which contains references to numerous
#    packages needed for building software in general, it contais g++, gcc,
#    make tool between others package
#
#    curl is used in command lines or scripts to transfer data
#
#    libpq-dev are header files and static library for compiling C programs to
#    link with the libpq library in order to communicate with a PostgreSQL
#    database backend.
#
#    libxml2-dev Development files for the GNOME XML library
#
#    libxslt1-dev XSLT is an XML language for defining transformations of XML
#    files from XML to some other arbitrary format, such as XML, HTML, plain
#    text, etc.
#
#    imagemagick is a free and open-source software suite for displaying,
#    creating, converting, modifying, and editing raster image.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get install -y curl         \
                       libpq-dev    \
                       libxml2-dev  \
                       libxslt1-dev \
                       imagemagick


# --------------------------
# INSTALL NODEJS BY NVM
# --------------------------
ARG NODE_VERSION=12.16.1
ARG NVM_DIR=/usr/local/nvm

# https://github.com/creationix/nvm#install-script
RUN mkdir $NVM_DIR && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v
# --------------------------
# end NODEJS
# --------------------------


# Install YARN
RUN npm install -g yarn


# ADD an user called devel
# --gecos GECOS
#          Set  the  gecos (information about the user) field for the new entry generated.  adduser will
#          not ask for finger information if this option is given
#
# The users of the group staff can install executables in /usr/local/bin and /usr/local/sbin without root privileges
RUN adduser -u 2000 --disabled-password --gecos '' devel \
  && usermod -a -G sudo devel \
  && usermod -a -G staff devel \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo 'devel:devel' | chpasswd


# Define environment variables
ENV HOME /home/devel
ENV APP /var/www/app
ENV BUNDLE_PATH /bundle/vendor


# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT commands.
RUN mkdir -p $HOME \
  && mkdir -p $APP \
  && mkdir -p $BUNDLE_PATH \
  && chown -R devel:devel $HOME \
  && chown -R devel:devel $BUNDLE_PATH \
  && chown -R devel:devel $APP


USER devel:devel
WORKDIR $APP


# Install bundler and rails
RUN gem install bundler -v 2.1.4 \
 && gem install rails -v 6.0.2.1
