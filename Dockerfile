FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client build-essential libpq-dev

RUN useradd -m appuser

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN mkdir -p /usr/local/bundle && chown -R appuser:appuser /app /usr/local/bundle

USER appuser

RUN bundle check || bundle install --jobs 4 --retry 3

COPY --chown=appuser:appuser . .

COPY --chmod=0755 entrypoints/docker-entrypoint /usr/local/bin/docker-entrypoint
COPY --chmod=0755 entrypoints/sidekiq-entrypoint /usr/local/bin/sidekiq-entrypoint

EXPOSE 3000
