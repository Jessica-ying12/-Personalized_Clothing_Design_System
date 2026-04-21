# 设置环境变量
ARG DOMAIN_ADMIN="http:\/\/192.168.11.42:9089"
# 请求默认前缀
ARG DOMAIN_ADMIN_PREFIX="\/prod-api"

FROM node:lts-alpine AS builder
ARG DOMAIN_ADMIN
ARG DOMAIN_ADMIN_PREFIX
# 设置 Yarn 使用淘宝镜像（可选，根据需要）
RUN yarn config set registry https://registry.npmmirror.com

# 设置工作目录
WORKDIR /app

# 复制 package 管理文件
COPY package*.json ./

# 使用 Yarn 安装依赖
RUN yarn install

# 复制项目文件
COPY . .

# 环境变量文件
RUN mv .env.sample .env
RUN sed -i "s/\${DOMAIN_ADMIN}/$DOMAIN_ADMIN/g" .env && \
    sed -i "s/\${DOMAIN_ADMIN_PREFIX}/$DOMAIN_ADMIN_PREFIX/g" .env

# 生产构建（使用 Yarn 脚手架）
RUN yarn build

# 使用 Nginx 镜像提供服务
FROM nginx:latest
ARG DOMAIN_ADMIN
ARG DOMAIN_ADMIN_PREFIX

# 复制构建后的文件到 Nginx 的默认静态文件目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 拷贝自定义的 Nginx 配置文件
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

RUN sed -i "s/\${DOMAIN_ADMIN}/$DOMAIN_ADMIN/g" /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]