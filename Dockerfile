FROM ruby:3.4.4

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4567

CMD ["rerun", "ruby", "app.rb", "--background", "--", "-o", "0.0.0.0"]