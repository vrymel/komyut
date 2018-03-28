FROM vrymel/docker-elixir-phoenix:1.6.4

ENV APP_ENV development
ENV GOOGLE_MAP_API_KEY "AIzaSyC-I_k-BRAo2lm3Rce2krNICI0taTfLz0I"
# ENV WAYPOINTS_DIRECT_KEY_FILE ""
# ENV WAYPOINTS_DIRECT_CERT_FILE ""
ENV SENTRY_FRONTEND_DSN "https://e276c6caa7e24b1a83e233a3880ff3de@sentry.io/293950"
ENV SENTRY_BACKEND_DSN "https://2a7117de9ab04e0faf325c15d760128b:f5d5aea8d8db447e962da878313e60ca@sentry.io/293948"
ENV AUTH0_DOMAIN "vapps.auth0.com"
ENV AUTH0_CLIENT_ID "b5Hb86MTNMlYXlCLWWPrf9e9at2l4svs"
ENV AUTH0_CLIENT_SECRET "1FaQntko218v8LVTIHDvmIPBERH_5wep_UWvqJ5tEMVLd3gJWd6tkpBtzymI4tP3"

COPY ./app_develop /opt/app

WORKDIR /opt/app

# run this manually instead
# > docker-compose run web mix deps.get
# mix deps.get

# run this manually instead
# > docker-compose run web bash, then do the install
# RUN cd assets && \
    # npm install && \
    # cd ..

CMD "/bin/bash"
