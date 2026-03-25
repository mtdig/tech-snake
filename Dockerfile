FROM nginx:alpine
COPY ./apache2 /usr/share/nginx/html
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf
