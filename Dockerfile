FROM ruby:2.1
RUN apt-get update -qq && apt-get install -y \
  libpq-dev \
  postgresql-client \
  default-jre

RUN mkdir -p /toshi
WORKDIR /toshi

RUN gem install bundler -v '1.15.4'
ADD Gemfile /toshi/
ADD Gemfile.lock /toshi/
RUN bundle install --system

COPY . /toshi

EXPOSE 5000

CMD ["bundle", "exec", "puma"]
