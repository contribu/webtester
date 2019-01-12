FROM ruby:2.5.3

ENV APP_ROOT /app
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
WORKDIR $APP_ROOT

COPY .gemrc /root
COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT
RUN bundle install --jobs=8 --retry=3

COPY . $APP_ROOT
