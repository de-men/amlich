FROM google/dart

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline
ENV PATH="${PATH}:/root/.pub-cache/bin"
RUN pub global activate webdev

CMD ["webdev", "serve", "--hostname", "0.0.0.0", "-r", "web"]
