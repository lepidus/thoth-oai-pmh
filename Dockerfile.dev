FROM ruby:3.4.4-alpine

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apk add --no-cache \
    build-base \
    git \
    && rm -rf /var/cache/apk/*

RUN bundle install

COPY . .

EXPOSE 4567

CMD ["rerun", "ruby", "app.rb", "--background", "--", "-o", "0.0.0.0"]