FROM ruby:3.4.4-alpine

RUN apk add --no-cache build-base git

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4567

CMD ["rerun", "ruby", "app.rb", "--background", "--", "-o", "0.0.0.0"]