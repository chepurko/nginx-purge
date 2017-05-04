FROM nginx:1.12

LABEL maintainer "tech@abaranovskaya.com"

ENV \
    HOME=/root \
    GNUPGHOME=/root/.gnupg \
    DEBIAN_FRONTEND=noninteractive \
    NGX_CACHE_PURGE_VERSION=2.4.1 \
    NAXSI_VERSION=0.55.3

# Install basic packages and build tools
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
      wget \
      gnupg2 dirmngr \
      ca-certificates \
      build-essential \
      libssl-dev \
      libpcre3 \
      libpcre3-dev \
      zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# download and extract sources
RUN NGINX_VERSION=`nginx -V 2>&1 | grep "nginx version" | awk -F/ '{ print $2}'` && \
    cd /tmp && \
    wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg2 --keyserver hkps.pool.sks-keyservers.net --recv-keys 520A9993A1C052F8 && \
    gpg2 --verify nginx-${NGINX_VERSION}.tar.gz.asc nginx-${NGINX_VERSION}.tar.gz && \
  
    wget https://github.com/nginx-modules/ngx_cache_purge/archive/$NGX_CACHE_PURGE_VERSION.tar.gz \
         -O ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
         
    wget https://github.com/nbs-system/naxsi/archive/$NAXSI_VERSION.tar.gz \
         -O naxsi-$NAXSI_VERSION.tar.gz && \
    wget https://github.com/nbs-system/naxsi/releases/download/$NAXSI_VERSION/naxsi-$NAXSI_VERSION.tar.gz.asc && \
    gpg2 --keyserver hkps.pool.sks-keyservers.net --recv-keys 251A28DE2685AED4 && \
    gpg2 --verify naxsi-${NAXSI_VERSION}.tar.gz.asc naxsi-${NAXSI_VERSION}.tar.gz && \
    
    rm -r "$GNUPGHOME" nginx-${NGINX_VERSION}.tar.gz.asc naxsi-${NAXSI_VERSION}.tar.gz.asc && \
    
    tar -xf nginx-$NGINX_VERSION.tar.gz && \
    mv nginx-$NGINX_VERSION nginx && \
    rm nginx-$NGINX_VERSION.tar.gz && \
    
    tar -xf ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    mv ngx_cache_purge-$NGX_CACHE_PURGE_VERSION ngx_cache_purge && \
    rm ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    
    tar -xf naxsi-$NAXSI_VERSION.tar.gz && \
    mv naxsi-$NAXSI_VERSION naxsi && \
    rm naxsi-$NAXSI_VERSION.tar.gz && \

    apt-get purge -y gnupg2 dirmngr && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# configure and build
RUN cd /tmp/nginx && \
    BASE_CONFIGURE_ARGS=`nginx -V 2>&1 | grep "configure arguments" | cut -d " " -f 3-` && \
    /bin/sh -c "./configure --with-debug --add-module=/tmp/naxsi/naxsi_src --add-module=/tmp/ngx_cache_purge \
        ${BASE_CONFIGURE_ARGS}" && \
    make && make install && \
    rm -rf /tmp/nginx*
