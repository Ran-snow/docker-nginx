# Docker image for nginx

Dockerfile 参考自官方的 [docker-nginx](https://github.com/nginxinc/docker-nginx/tree/master/mainline/alpine) 。  
使用的是 mainline alpine 版本构建的。  
基于 commit baa050df601b5e798431a9db458e16f53b1031f6 修改的此 Dockerfile 。

## 修改如下
1. 改用 [https://mirrors.aliyun.com](https://mirrors.aliyun.com) 镜像源，用以提升构建速度。
2. 使用最新版openssl , 并对openssl进行防篡改校验。
3. 启用 Nginx 对 TLS1.3 的支持。

## 更新至Nginx 1.15.9

## 热烈庆祝 Github 私有仓库开启免费时代 ！