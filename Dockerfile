FROM alpine:3

LABEL org.opencontainers.image.source=https://github.com/Ran-snow/docker-nginx
LABEL org.opencontainers.image.description="NGINX Docker"
LABEL org.opencontainers.image.licenses=GPL-3.0

ENV NGINX_VERSION 1.28.0
ENV OPENSSL_VERSION 3.0.16
ENV OPENSSL_CONF /etc/ssl/openssl.cnf

RUN GPG_KEYS_NGINX=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	&& GPG_KEYS_OPENSSL=0E604491 \
	&& CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
		--with-http_v3_module \
		--with-openssl=/usr/src/openssl-$OPENSSL_VERSION \
		--add-module=/usr/src/ngx_brotli \
		--add-module=/usr/src/ngx_http_geoip2 \
	" \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	\
	# && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		git \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev \
		g++ \
		libtool \
		automake \
		autoconf \
		libmaxminddb-dev \
	&& git clone --depth=1 --recurse-submodules https://github.com/google/ngx_brotli.git /usr/src/ngx_brotli \
	&& git clone --depth=1 --recurse-submodules https://github.com/leev/ngx_http_geoip2_module.git /usr/src/ngx_http_geoip2 \
	&& curl -fSL https://freenginx.org/download/freenginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL https://freenginx.org/download/freenginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
	&& curl -fSL https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz  -o openssl.tar.gz \
	&& curl -fSL https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz.asc  -o openssl.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& found=''; \
	for server in \
		keys.gnupg.net \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching NGINX GPG key $GPG_KEYS_NGINX from $server"; \
		echo "Fetching OPENSSL GPG key $GPG_KEYS_OPENSSL from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS_NGINX" "$GPG_KEYS_OPENSSL" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS_NGINX $GPG_KEYS_OPENSSL" && exit 1; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz; \
	gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz; \
	rm -rf "$GNUPGHOME" nginx.tar.gz.asc openssl.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& tar -zxC /usr/src -f openssl.tar.gz \
	&& rm nginx.tar.gz \
	&& rm openssl.tar.gz \
	&& cd /usr/src/freenginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& mv objs/nginx objs/nginx-debug \
	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
	&& mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
	&& install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& rm -rf /usr/src/freenginx-$NGINX_VERSION \
	&& rm -rf /usr/src/openssl-$OPENSSL_VERSION \
	&& rm -rf /usr/src/ngx_brotli \
	&& rm -rf /usr/src/ngx_http_geoip2 \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# Bring in tzdata so users could set the timezones through the environment
	# variables
	&& apk add --no-cache tzdata ca-certificates \
	&& cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]