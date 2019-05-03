FROM ruby:2.3-slim

ENV RAILS_ENV=production \
    APT_ARGS="-y --no-install-recommends --no-upgrade -o Dpkg::Options::=--force-confnew"

# Copy ENTRYPOINT script
ADD docker-entrypoint.sh /entrypoint.sh

RUN apt-get update && \
# Install requirements
    DEBIAN_FRONTEND=noninteractive \
    apt-get install $APT_ARGS \
      gcc \
      git \
      g++ \
      build-essential \
      libsqlite3-dev \
      make \
      nodejs \
      patch \
      default-libmysqlclient-dev \
      wget && \
# Install Dradis
    cd /opt && \
    git clone -b release-3.12 https://github.com/dradis/dradis-ce.git && \
    cd dradis-ce/ && \
    ruby bin/setup && \
    bundle install && \
#    exec bundle exec rake resque:work && \
# Entrypoint:
    chmod +x /entrypoint.sh && \
# Create dradis user:
    groupadd -r dradis-ce && \
    useradd -r -g dradis-ce -d /opt/dradis-ce dradis-ce && \
    mkdir -p /dbdata && \
    chown -R dradis-ce:dradis-ce /opt/dradis-ce/ /dbdata/ && \
# Clean up:
    apt-get remove -y --purge \
      gcc \
      g++ \
      build-essential \
      libsqlite3-dev \
      make \
      patch \
      wget && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install $APT_ARGS \
      libsqlite3-0 && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* && \
    rm -f /dbdata/production.sqlite3 && \
    mv templates templates_orig && \
    mkdir -p templates && \
    chown -R dradis-ce:dradis-ce templates

WORKDIR /opt/dradis-ce

VOLUME /dbdata
VOLUME /opt/dradis-ce/templates

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
