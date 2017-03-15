FROM ruby:2.3.3

RUN apt-get update && apt-get install -y \
      build-essential \
      wget \
      git-core \
      libxml2 \
      libxml2-dev \
      libxslt1-dev \
      nodejs \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir /gilded_rose

WORKDIR /gilded_rose

ENV GEM_HOME /bundle
ENV PATH $GEM_HOME/bin:$PATH
ENV BUNDLE_PATH /bundle
ENV BUNDLE_BIN /bundle/bin
ENV PATH $BUNDLE_BIN/bin:$PATH

RUN gem install bundler \
    && bundle config --global path "$GEM_HOME" \
    && bundle config --global bin "$GEM_HOME/bin" \
    && gem install rspec
