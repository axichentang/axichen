FROM alpine:3.20

RUN apk add --no-cache wget tar socat

WORKDIR /app

COPY NOTICE.txt .

RUN wget https://github.com/SagerNet/sing-box/releases/download/v1.13.13/sing-box-1.13.13-linux-amd64.tar.gz && \
    tar -zxvf sing-box-1.13.13-linux-amd64.tar.gz && \
    mv sing-box-1.13.13-linux-amd64/sing-box ./ && \
    rm -rf sing-box-1.13.13-linux-amd64*

COPY config.json .

EXPOSE 8080

# 在后台启动一个简单的 HTTP 服务返回 OK（监听 8081）
RUN mkdir -p /www && echo "OK" > /www/index.html

# 使用 socat 将 8080 的流量转发：若是 HTTP GET 则返回 /www/index.html，否则转发到 8081（VLESS）
# 这里使用 socat 的 OPENSSL 或 TCP 转发，但判断逻辑复杂

# 我们改用两个独立服务：HTTP 服务在 8081，sing-box 在 8080，但外部只能访问一个端口。
# 因此必须让 sing-box 能处理 HTTP，但 fallback 不工作。
