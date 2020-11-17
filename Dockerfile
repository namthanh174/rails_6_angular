FROM ruby:2.7
# Add Yarn to the repository
RUN curl https://deb.nodesource.com/setup_12.x | bash     && curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -     && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# Install system dependencies & clean them up

RUN apt-get update -qq && apt-get install -y \
    postgresql-client build-essential yarn nodejs \
    libnotify-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
# Allow access to port 3000
EXPOSE 3000
EXPOSE 3035
RUN yarn install --check-files
RUN rails webpacker:install

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
