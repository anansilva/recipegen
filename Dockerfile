### BASE ###
FROM ruby:3.2.2 as base
RUN apt-get update -qq && apt-get install -y postgresql-client vim nodejs imagemagick ffmpeg poppler-utils libvips-tools
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

ENV BUNDLER_VERSION 2.4.12
RUN gem update --system \
    && gem install bundler -v $BUNDLER_VERSION \
        && bundle install -j 4

### CI ###
FROM base as ci

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

ADD . /app

