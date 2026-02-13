FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client build-essential libpq-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle check || bundle install

COPY . .

COPY --chmod=0755 ./bin/docker-entrypoint ./bin/docker-entrypoint

ENTRYPOINT ["./bin/docker-entrypoint"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
