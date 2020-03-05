FROM amazonlinux:2018.03

SHELL ["/bin/bash", "--login", "-c"]

RUN yum -y install git vim gcc gcc-c++ bzip2 readline-devel zlib-devel sqlite-devel openssl-devel postgresql-devel

RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

RUN rbenv install 2.6.3 && rbenv global 2.6.3

RUN gem install bundler

WORKDIR /root/developer

EXPOSE 8000
EXPOSE 5432
