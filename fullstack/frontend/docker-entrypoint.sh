#!/bin/sh
envsubst '${BACKEND_URL}' < /usr/share/nginx/html/client.html.template > /usr/share/nginx/html/client.html
exec nginx -g 'daemon off;'