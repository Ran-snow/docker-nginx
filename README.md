# Docker image for nginx

Dockerfile 参考自官方的 [docker-nginx](https://github.com/nginxinc/docker-nginx/tree/master/mainline/alpine) 。  
使用的是 mainline alpine 版本构建的。  

基于 commit baa050df601b5e798431a9db458e16f53b1031f6 修改的此 Dockerfile 。

## 更新至 Nginx(mainline version) 1.25.5
## 更新至 Nginx(stable version) 1.24.0

## Dockerfile

* [Dockerfile](https://github.com/Ran-snow/docker-nginx/blob/master/Dockerfile)

## 架构支持

> linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v8

## 修改如下
1. ~~改用 [https://mirrors.aliyun.com](https://mirrors.aliyun.com) 镜像源，用以提升构建速度。~~
2. 使用openssl 3.0.13, 并对openssl进行防篡改(gpg)校验。
3. 启用 Nginx 对 TLS1.3/http2/http3(>=1.25.0)/brotli/geoip2 的支持。
4. 使用东八时区。
5. 预设“Modern configuration”型配置文件示例。
6. 暂不支持TLS1.3 0-RTT [early data](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_early_data)
7. 使用freenginx

## IP库下载地址

自行替换年月
```
wget https://download.db-ip.com/free/dbip-country-lite-2022-02.mmdb.gz
gunzip dbip-country-lite-2022-02.mmdb.gz
```

## Docker Pull Command

```
docker pull rsnow/nginx:1.25.5
```

## 更多

[Nginx Docker Official Images](https://hub.docker.com/_/nginx)

此仓库始于 Github 私有仓库开启免费使用宣布日(Jan 8, 2019) ！


https://docs.docker.com/build/ci/github-actions/multi-platform/