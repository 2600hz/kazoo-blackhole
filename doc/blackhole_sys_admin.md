# Configuring Blackhole

## Starting the app

Start the Blackhole application on {% BRAND_NAME %} (if it is not running already), the command below will add Blackhole to the list of startup application too:

```bash
sup kazoo_apps_maintenance start_app blackhole
```

## Blackhole System Configuration

The configuration resides in `system_config/blackhole`. You can configure these parameters using `sup` command or Crossbar API (if you're superduper admin).

(Always check `system_config.blackhole` JSON schema for up to date list of parameters).

Main configuration parameters are:

* `ip`: the IP that Blackhole should bind into, default is `0.0.0.0`
* `port`: port for unsecure websocket, default is `5555`
* `use_plaintext`: should Blackhole starts unsecure server, default is `true`
* `user_ssl`: should Blackhole starts secure server, default is `false`

## Secure (WSS) WebSocket Server

You can either use [HAProxy](./haproxy.md) as SSL termination (recommended) or configure Blackhole to start a secure server.

If you want to start a secure server you must provide SSL certificate and its password:

* `ssl_ca_cert`: SSL CA certificate
* `ssl_cert`: SSL certificate
* `ssl_key`: SSL Key
* `ssl_password`: SSL Key password
* `ssl_port`: SSL port to listen, default is `5556`

## Secure (WSS) WebSocket using HAProxy

See [HAProxy](./haproxy.md).
