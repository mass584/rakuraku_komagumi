FROM amazonlinux:2

SHELL ["/bin/bash", "--login", "-c"]

RUN yum -y install git make vim gcc gcc-c++ tar unzip bzip2 readline-devel zlib-devel sqlite-devel openssl-devel postgresql-devel GConf2

RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    git clone https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update

RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

RUN rbenv update && rbenv install 3.0.0 && rbenv global 3.0.0

RUN git clone git://github.com/nodenv/nodenv.git ~/.nodenv && \
    git clone git://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build && \
    git clone https://github.com/pine/nodenv-yarn-install.git ~/.nodenv/plugins/nodenv-yarn-install

RUN echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(nodenv init -)"' >> ~/.bash_profile

RUN nodenv install 10.17.0 && nodenv global 10.17.0

RUN gem install bundler

EXPOSE 3000
