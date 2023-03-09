FROM ubuntu:jammy

WORKDIR /app

COPY . /app/src/

RUN apt update && apt install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev
RUN cd src/ \
    && ./auto/configure --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log \
                        --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid \
                        --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module \
                        --with-stream=dynamic --with-http_addition_module --with-http_mp4_module \
    && make \
    && make install



CMD ["nginx", "-g", "daemon off;"]