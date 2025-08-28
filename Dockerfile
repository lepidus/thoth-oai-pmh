FROM ruby:3.4.4-alpine

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apk add --no-cache \
    build-base \
    git \
    && rm -rf /var/cache/apk/*

RUN bundle install

COPY . .

RUN rm -rf tests/ Rakefile

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]