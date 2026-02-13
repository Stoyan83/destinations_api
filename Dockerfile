FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client build-essential libpq-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle check || bundle install

COPY . .

COPY --chmod=0755 entrypoints/docker-entrypoint /usr/local/bin/docker-entrypoint
COPY --chmod=0755 entrypoints/sidekiq-entrypoint /usr/local/bin/sidekiq-entrypoint

EXPOSE 3000
