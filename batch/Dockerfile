FROM amazonlinux:2018.03

SHELL ["/bin/bash", "--login", "-c"]

RUN yum -y install git vim gcc gcc-c++ bzip2 openssl-devel readline-devel zlib-devel postgresql-devel epel-release libffi-devel

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv

RUN echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

RUN pyenv install 3.7.3 && pyenv global 3.7.3

RUN pip install --upgrade pip && \
    pip install numpy && \
    pip install psycopg2 && \
    pip install awscli && \
    pip install boto3

WORKDIR /root/developer

EXPOSE 5432
