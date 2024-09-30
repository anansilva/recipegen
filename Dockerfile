FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y postgresql-client vim
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

ENV BUNDLER_VERSION 2.3.16
RUN gem update --system \
    && gem install bundler -v $BUNDLER_VERSION \
        && bundle install -j 4

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
