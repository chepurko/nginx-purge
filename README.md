# NGINX Compiled with `ngx_cache_purge` and `naxsi` Modules

This image is based on the official ``nginx:stable`` ([see on Dockehub](https://hub.docker.com/_/nginx/)) and recompiled with the same configure options from vanilla NGINX sources with addition of `--add-module=ngx-cache-purge --add-module=naxsi`.

[The fork](https://github.com/nginx-modules/ngx_cache_purge) of the [original FRiCLE's module](http://labs.frickle.com/nginx_ngx_cache_purge/) is used, which...

* is compatible with modern nginx
* supports purging by partial keys (``*`` at the end) (see [release notes](https://github.com/nginx-modules/ngx_cache_purge/releases))

NBS System's [NAXSI module](https://github.com/nbs-system/naxsi) is also used;

* NAXSI means [Nginx]( http://nginx.org/ ) Anti [XSS]( https://www.owasp.org/index.php/Cross-site_Scripting_%28XSS%29 ) & [SQL Injection]( https://www.owasp.org/index.php/SQL_injection )
