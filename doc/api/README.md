# How to use Blackhole API

## Quick Start

1. To interact with Blackhole API, you need to authenticate with
   API first. You can use Crossbar HTTP API to perform
   authentication (over HTTP protocol) and use the resulting Auth Token when
   sending the request to WebSocket. See Crossbar's
   [How to authenticate](https://docs.2600hz.com/git/2600hz/kazoo-crossbar/doc/how_to_authenticate.md)
   to learn more authentication methods.
1. Make a connection to Blackhole using WebSocket API
1. Tell WebSocket API what to do when it receives a message (reply) from
   Blackhole (take action on certain messages or show them in UI)
1. Once the connection is established, the client and server can send WebSocket
   data or text frames back and forth in full-duplex mode.

### Example JavaScript code

Here a quick and simple code to show how to use websocket. You need a web browser, open its Web Developer Tools. Go to Console tab type these codes.

Please keep in mind you web browser should have access to the Blackhole IP address.

```javascript
    // use Crossbar HTTP API to authenticate and get an AuthToken
    const authToken = '{AUTH_TOKEN}';

    // ws: if this unsecure connection use "ws", for secure connection use "wss"
    // {BLACKHOLE_IP}: the IP address / domain name to access the Blackhole server
    // {BLACKHOLE_PORT}: the port Blackhole is using (default value is 5555 for ws, and 5556 for wss)
    var socket = new WebSocket("ws://{BLACKHOLE_IP_ADDRESS}:5555");

    socket.onmessage = function(response) {
        var json = JSON.parse(response.data);
        console.log(json);
    };

    socket.send(JSON.stringify({
        action: 'ping',
        auth_token: authToken,
        request_id: '{RANDOM_UUID}',
        data: {}
    }));
    // in console you'll see something like:
    // {"action":"reply","request_id":"{RANDOM_UUID}","status":"success","data":{"response":"pong"}}
```

Here is a simple full example to subscribe to `CHANNEL_CREATE` events, Conference events, and user creation events. Save this as `example_blackhole.html`, and replace `{BLACKHOLE_IP_ADDRESS}` with IP address if blachole.
Since modern Web browsers for security reason block using Webscoket from a local opened file for security reasons, we need a HTTP server to serve the HTML.
Open your favorite terminal, change directory to where you save this file. Run `python3 -m http.server 8080` and now you can browser http://localhost:8080/example_blackhole.html.

```html
<html>
  <head>
  </head>
  <body>
    <script>
        var socket = new WebSocket("ws://{BLACKHOLE_IP_ADDRESS}:5555");

        function send(data) {
            socket.send(JSON.stringify(data));
        }

        socket.onopen = function() {
            send({
                action: 'subscribe',
                auth_token: '{AUTH_TOKEN}',
                request_id: '{REQUEST_ID}',
                data: {
                    account_id: '{ACCOUNT_ID}',
                    binding: 'call.CHANNEL_CREATE.*'
                }
            });

            send({
                action: 'subscribe',
                auth_token: '{AUTH_TOKEN}',
                request_id: '{REQUEST_ID}',
                data: {
                    account_id: '{ACCOUNT_ID}',
                    binding: 'conference.event.{CONFERENCE_ID}.*'
                }
            });

            send({
                action: 'subscribe',
                auth_token: '{AUTH_TOKEN}',
                request_id: '{REQUEST_ID}',
                data: {
                    account_id: '{ACCOUNT_ID}',
                    binding: 'doc_created.*.user.*'
                }
            });
        }

        socket.onmessage = function(raw_message) {
            var json_data = JSON.parse(raw_message.data);

            console.log(json_data);
        };
    </script>
  </body>
</html>
```

## Blackhole API Basics

All communications in Blackhole are based on JSON object messages unless otherwise is specified.

### Request Envelope message

For possible values for `action` see [List of Blackhole API](#list-of-blackhole-api) below.

Key | Description | Type | Default | Required
--- | ----------- | ---- | ------- | --------
`action` | the requested operation, default action `noop` will not performing any operation or replies no responses | `string()` |  `noop` | `false`
`auth_token` | Your auth token | `string()` |  | `true`
`data` | contains the data needed by the action | `object()` |  | `false`
`request_id` |A unique ID of for the request; usable for debugging of the request or keeping track of replies later. | `string()` |  | `false`

Example request to subscribe to receive events every time a channel is generated:

```json
{
    "action": "subscribe",
    "auth_token": "{AUTH_TOKEN}",
    "request_id": "{REQUEST_ID}",
    "data": {
        "account_id": "{ACCOUNT_ID}",
        "binding": "call.CHANNEL_CREATE.*"
    }
}
```

### Response message

Depends on requested action and operation you may receive a reply message from WebSocket (don't forget to use JavaScript WebSocket API to bind `onmessage`).

#### Common request reply

This is a common reply to a request.

* `{REQUEST_ID}` is the same as the request
* `status` indicates the request was successful or not (`error`)
* `data` is arbitrary object


```json
{
    "action": "reply",
    "request_id": "{REQUEST_ID}",
    "status": "success",
    "data": {
    }
}
```

## List of Blackhole API

* [`api`](./actions/bh_api.md): Channel through your Crossbar request, will send the reply to that request later.
* [`ping`](./actions/bh_ping.md): Sends a reply with data `{"response":"pong"}`. Useful to check if the WebSocket connect is alive.
* [`subscribe`](./actions/bh_events.md): Subscribe and bind to receive specified {% BRAND_NAME %} events.
* [`unsubscribe`](./actions/bh_events.md): Unsubscribe and unbind from specified {% BRAND_NAME %} events.
