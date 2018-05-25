#!/bin/bash

mix deps.get --only production

cd assets && npm install && ./node_modules/.bin/brunch build --production && cd ..

MIX_ENV=prod mix phx.digest

MIX_ENV=prod mix release --env=prod

REPLACE_OS_VARS=true PORT=4000 _build/prod/rel/waypoints_direct/bin/waypoints_direct foreground