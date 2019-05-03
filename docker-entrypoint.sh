#!/bin/bash

# Exit the script in case of errors
set -e

SECRET_KEY_BASE="${SECRET_KEY_BASE:-$(bundle exec rake secret)}"
export SECRET_KEY_BASE

RAILS_SERVE_STATIC_FILES="true"
export RAILS_SERVE_STATIC_FILES

REDIS_URL="redis://dradis-redis:6379/1"
export REDIS_URL

cp -r -n /opt/dradis-ce/db/*.sqlite3 /dbdata/
cp -r -n /opt/dradis-ce/templates_orig/* /opt/dradis-ce/templates/
chown -R dradis-ce /dbdata/ /opt/dradis-ce/templates
chmod -R u+w /dbdata/ /opt/dradis-ce/templates

if [ -z "${*}" ]
then
  exec su -m -l dradis-ce -c 'exec bundle exec rake resque:work & bundle exec rails server -b 0.0.0.0'
else
  exec su -m -l dradis-ce -c 'exec bundle exec rake resque:work & bundle exec rails server "$0" "$@"' -- "${@}"
fi
