#!/bin/bash

mix deps.get --only production
MIX_ENV=prod mix compile

cd ./app/assets

npm install 

./node_modules/.bin/brunch build --production 

# If node-sass error, do
# npm rebuild node-sass

cd ../..

# phx.digest depends on the priv/static directory which should be 
# created/updated if brunch build --production succeeds. If the assets are not updated
# check if brunch build --production succeeded.
MIX_ENV=prod mix phx.digest