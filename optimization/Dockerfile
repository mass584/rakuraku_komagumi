FROM amazonlinux:2

SHELL ["/bin/bash", "--login", "-c"]

RUN yum -y install git make vim htop gcc gcc-c++ tar unzip bzip2 bzip2-devel readline readline-devel zlib-devel sqlite sqlite-devel openssl openssl-devel libffi-devel libcurl-devel postgresql-devel

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv && \
    git clone https://github.com/yyuu/pyenv-update.git ~/.pyenv/plugins/pyenv-update

RUN echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile

RUN pyenv update && pyenv install 3.7.1 && pyenv global 3.7.1

RUN pip install --upgrade pip
RUN pip install numpy psycopg2 awscli pycodestyle autopep8 line_profiler
