#!/bin/sh

# Update API KEY from env variable. Not really sure why running this on dockerfile doesn't work..
echo "$API_KEY" >APIKEY.txt && echo "$SESSION_KEY" >SESSIONKEY.txt

exec "$@"

