# Blackhole HAProxy Configuration

## Configuration for API and Websockets

Combining a HTTP listener for both API and Websockets:

```
listen kazoo-crossbar-https
        bind *:8443 ssl crt /etc/haproxy/certs/mycert.pem
        mode http
        option httplog
        option dontlognull
        acl is_blackhole path_beg /socket.io/
        use_backend kapps-blackhole if is_blackhole
        default_backend kapps-crossbar
backend kapps-blackhole
  balance source
    mode http
    option forwardfor
    option http-server-close
    option forceclose
    no option httpclose
    option httpchk HEAD  /

   server srv-01 srv-01.mydomain.com:5555 check
   server srv-02 srv-02.mydomain.com:5555 check
   server srv-03 srv-03.mydomain.com:5555 check
   server srv-04 srv-04.mydomain.com:5555 check

```

Then Configuring Monster UI to use the IP and port for both HTTP and websocket.

Edit `js/config.js` Monster UI file as follow:


```javascript hl_lines="4 5"
define({
    api: {
        default: 'https://api.mydomain.com:8443/v2/',
        socket: 'https://api.mydomain.com:8443'
    },
    ...
});
```

## WSS considerations

In order you'd like to secure your Websocket connection, you can use HAProxy SSL Termination.

Edit your HAProxy config `/etc/kazoo/haproxy/haproxy.cfg`:

```
global
        ....
        tune.ssl.default-dh-param 2048
        ....

defaults
        ....
        timeout tunnel 1h
        ....
```

(add the next sections at the end of the config file)

```
frontend secure_blackhole
        bind 0.0.0.0:7777 ssl crt /etc/kazoo/haproxy/cert_key.pem
        timeout client 1h
        default_backend www_blackhole
        acl is_websocket hdr(Upgrade) -i WebSocket
        use_backend websocket_blackhole if is_websocket

backend www_blackhole
        mode http
        stats enable
        stats uri /haproxy
        option forwardfor
        reqadd x-forwarded-proto:\ https
        server server1 127.0.0.1:5555 weight 1 maxconn 8192

backend websocket_blackhole
        mode http
        option forwardfor
        option http-server-close
        option forceclose
        no option httpclose
        server server1 127.0.0.1:5555 weight 1 maxconn 8192
```


Here is how `cert_key.pem` should look like:

```shell
[root@kz527 ~]# cat /etc/kazoo/haproxy/cert_key.pem
-----BEGIN CERTIFICATE-----
MIIF0jCCBLqgAwIBAgIRAOQQ6+NpkZwOENe2OQiJlW4wDQYJKoZIhvcNAQEFBQAw
..........
LE5OWycye7miZLmgtC6ZkI6HI7KJuIEcfeYaBSpENinOXs0OjvmGBYELgNymAw2L
FG3/ESMR
-----END CERTIFICATE-----
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBSKDCAQEA0roiYyzi4Auuu2qJ/2uWsmUnNHjKqvWXd6iMf2aNbOKcVVps
..........
V8MsGq2IA+2FmrRrd0jYfh8iu1VydbmySghjs69HtYNPndfhs37HtH0=
-----END RSA PRIVATE KEY-----
```

Now you can use `7777` port for your blackhole WSS connections.


Config was created to connect Kazoo-Popup secure and wasn't fully tested,
so treat it as a hint needed to be proved before putting into production.
