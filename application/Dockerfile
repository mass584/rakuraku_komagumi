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

WORKDIR /root/tmp

RUN curl https://intoli.com/install-google-chrome.sh | bash

RUN wget https://chromedriver.storage.googleapis.com/90.0.4430.24/chromedriver_linux64.zip

RUN unzip chromedriver_linux64.zip && mv chromedriver /usr/local/bin/

RUN wget https://noto-website-2.storage.googleapis.com/pkgs/Noto-hinted.zip

RUN unzip Noto-hinted.zip && mkdir -p /usr/share/fonts/opentype/noto && mv *otf *ttf /usr/share/fonts/opentype/noto

EXPOSE 3000
