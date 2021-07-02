# Subscribe to KAZOO events

This API provide a way to subscribe to KAZOO event using binding and receive them on websoxckert message in real time. Effectively this API provides an AMQP->Websocket bridge, providing you with real-time event streams about calls, API changes, and more.

## Authorization

Some events may need to check if you are authorized to access to event binding or not, please check the event documentation for more info.

## Request Payload

This is common a request to either `subscribe` or `unsubscribe` actions.

See [Binding string syntax](#binding-string-syntax) below to learn about the format of binding string.

Key | Description | Type | Default | Required
--- | ----------- | ---- | ------- | --------
`action` | to subscribe or unsubscribe | `string('subscribe' | 'unsubscribe')` |  | `true`
`data.account_id` | The account ID to use for binding | `string()` |  | `false`
`data.binding` | Binding string to use | `string()` |  | `false`
`data.bindings` | A list of bindings to use | `array(string())` |  | `true`

Please note:

* If no `data.account_id` is present, the `account_id` from your `auth_token` will be used instead.
* `data.binding`  will be picked first over `data.bindings` in case both are present.

## List of events

* [`app_event`](../events/bh_app_event.md)
* [`call`](../events/bh_call.md)
* [`conference`](../events/bh_conference.md)
* [`fax`](../events/bh_fax.md)
* [`live`](../events/bh_live.md)
* [`object`](../events/bh_object.md)
* [`presence`](../events/bh_presence.md)

!!! note:
    You can get a list of available events and their bindings using Crossbar HTTP API [`GET /v2/websockets`](../../../../crossbar/doc/websockets.md#available-websocket-bindings).

### Response payload message

```json
{
    "action": "reply",
    "request_id": "{REQUEST_ID}",
    "status": "success",
    "data": {
        "subscribed": "SUBSCRIBED_KEY",
        "subscriptions": [
            "{ALL_SUBSCRIPTIONS}"
        ]
    }
}
```

## Event payload message

After you subscribe to events the Blackhole application will listen for those events from AMQP. It will send an event to you through Websockets if there is an active binding that matches this event.

Events are plain AMQP event messages.

```json
{
    "action": "event",
    "subscribed_key": "{SUBSCRIBED_KEY}",
    "subscription_key": "{SUBSCRIPTION_KEY}",
    "name": "{NAME}",
    "routing_key": "AMQP_ROUTING_KEY",
    "data": "{EVENT_AMQP_PAYLOAD}"
}
```

## Binding string syntax

The binding syntax is the same used throughout all KAZOO, since it is the same as AMQP's binding syntax.

Each binding is consist of multiple slots (or segments) separated by dot `.`, like `call.CHANNEL_CREATE.*`. Each slot is matches one slot in the event's routing key.

The are two specical characters:

* `*` in a slot matches exactly one slot with any value
* `#` in a slot matches zero or more slots with any value

Here are some examples:

* `call.CHANNEL_CREATE.123qweasdzxc` will matches call's `CHANNEL_CREATE` event with Call-ID `123qweasdzxc`.
* `call.CHANNEL_CREATE.*` will matches all call's `CHANNEL_CREATE` events (with any Call-ID)
* `app_event.mychatapp.room.123.#` will matches all `app_event` for `mychatapp.room.123` event with any possible remaining slots in routing keys (like `app_event.mychatapp.room.123.message.qaz`)

## Some examples of subscribe or unsubscribe

```javascript
// For one use: binding
// Binding to edit event of user documents
send({
    action: 'subscribe',
    auth_token: '{AUTH_TOKEN}',
    request_id: '{REQUEST_ID}',
    data: {
        account_id: '{ACCOUNT_ID}',
        binding: 'doc_edited.*.user.*'
    }
});

// For multiple use: bindings
// Binding to edit or deletion events of user documents
send({
    action: 'subscribe',
    auth_token: '{AUTH_TOKEN}',
    request_id: '{REQUEST_ID}',
    data: {
        account_id: '{ACCOUNT_ID}',
        bindings: ['doc_edited.*.user.*', 'doc_deleted.*.user.*']
    }
});
```

You can also add a friendly name and some metadata to any subscribe command.

```javascript
send({
    action: 'subscribe',
    auth_token: '{AUTH_TOKEN}',
    request_id: '{REQUEST_ID}',
    data: {
        account_id: '{ACCOUNT_ID}',
        name: "My new socket",
        metadata: {
            test: "test"
        },
        binding: 'doc_edited.*.user.*'
    }
});
```

To remove bindings use `unsubscribe` event:

```javascript
send({
    action: 'unsubscribe',
    auth_token: '{AUTH_TOKEN}',
    request_id: '{REQUEST_ID}',
    data: {
        account_id: '{ACCOUNT_ID}',
        binding: 'call.CHANNEL_CREATE.*'
    }
});
```

## Some examples for AMQP event payload

Events are plain AMQP event messages. Here are a few complete `call.*.*` JSON events (please keep in mind these are just for reference, consult the rest of KAZOO documentation to see current values):

```json
{
    "name": "CHANNEL_CREATE",
    "args": {
        "App-Name": "ecallmgr",
        "App-Version": "0.8.0",
        "Call-Direction": "inbound",
        "Call-ID": "at6dmu4ffk97vnlp6qfq",
        "Caller-ID-Name": "user_wpxnx7am9w",
        "Caller-ID-Number": "user_wpxnx7am9w",
        "Custom-Channel-Vars": {
            "Account-ID": "account0000000000000000000000002",
            "Account-Name": "wefwefwefwef",
            "Account-Realm": "wefwefwefwef.2600hz.com",
            "Authorizing-ID": "d509114b66efabf32dfd78dc464b46dd",
            "Authorizing-Type": "device",
            "Owner-ID": "699ed7e3d583e2577ac017c575f87262",
            "Realm": "wefwefwefwef.2600hz.com",
            "Register-Overwrite-Notify": "false",
            "Suppress-Unregister-Notifications": "false",
            "Username": "user_wpxnx7am9w"
        },
        "Custom-SIP-Headers": {
            "X-AUTH-IP": "192.168.25.203"
        },
        "Disposition": "DELAYED NEGOTIATION",
        "Event-Category": "call_event",
        "Event-Name": "CHANNEL_CREATE",
        "From": "356@wefwefwefwef.2600hz.com",
        "From-Tag": "l530ecbu2f",
        "From-Uri": "user_wpxnx7am9w@wefwefwefwef.2600hz.com",
        "Media-Server": "wef.2600hz.com",
        "Msg-ID": "1443672756993309",
        "Node": "ecallmgr@wef.2600hz.com",
        "Presence-ID": "356@wefwefwefwef.2600hz.com",
        "Request": "*97@wefwefwefwef.2600hz.com",
        "Switch-URI": "sip:192.168.25.216:11000",
        "Switch-URL": "sip:mod_sofia@192.168.25.216:11000",
        "Timestamp": 63610891956,
        "To": "*97@wefwefwefwef.2600hz.com",
        "To-Uri": "*97@wefwefwefwef.2600hz.com"
    }
}
```

```json
{
    "name": "CHANNEL_ANSWER",
    "args": {
        "App-Name": "ecallmgr",
        "App-Version": "0.8.0",
        "Call-Direction": "inbound",
        "Call-ID": "at6dmu4ffk97vnlp6qfq",
        "Caller-ID-Name": "web phone",
        "Caller-ID-Number": "356",
        "Custom-Channel-Vars": {
            "Account-ID": "account0000000000000000000000002",
            "Account-Name": "wefwefwefwef",
            "Account-Realm": "wefwefwefwef.2600hz.com",
            "Application-Name": "callflow",
            "Application-Node": "kazoo_apps@wef.2600hz.com",
            "Authorizing-ID": "d509114b66efabf32dfd78dc464b46dd",
            "Authorizing-Type": "device",
            "Bridge-ID": "at6dmu4ffk97vnlp6qfq",
            "Caller-Privacy-Name": "false",
            "Caller-Privacy-Number": "false",
            "Channel-Authorized": "true",
            "Ecallmgr-Node": "ecallmgr@wef.2600hz.com",
            "Fetch-ID": "a60aea8c-67f2-11e5-8465-3390f8e3460f",
            "Global-Resource": "false",
            "Owner-ID": "699ed7e3d583e2577ac017c575f87262",
            "Realm": "wefwefwefwef.2600hz.com",
            "Register-Overwrite-Notify": "false",
            "Suppress-Unregister-Notifications": "false",
            "Username": "user_wpxnx7am9w"
        },
        "Custom-SIP-Headers": {
            "X-AUTH-IP": "192.168.25.203"
        },
        "Disposition": "EARLY MEDIA",
        "Event-Category": "call_event",
        "Event-Name": "CHANNEL_ANSWER",
        "From": "356@wefwefwefwef.2600hz.com",
        "From-Tag": "l530ecbu2f",
        "From-Uri": "user_wpxnx7am9w@wefwefwefwef.2600hz.com",
        "Media-Server": "wef.2600hz.com",
        "Msg-ID": "1443672757935421",
        "Node": "ecallmgr@wef.2600hz.com",
        "Presence-ID": "356@wefwefwefwef.2600hz.com",
        "Request": "*97@wefwefwefwef.2600hz.com",
        "Switch-URI": "sip:192.168.25.216:11000",
        "Switch-URL": "sip:mod_sofia@192.168.25.216:11000",
        "Timestamp": 63610891957,
        "To": "*97@wefwefwefwef.2600hz.com",
        "To-Uri": "*97@wefwefwefwef.2600hz.com"
    }
}
```

```json
{
    "name": "CHANNEL_DESTROY",
    "args": {
        "App-Name": "ecallmgr",
        "App-Version": "0.8.0",
        "Billing-Seconds": "31",
        "Call-Direction": "inbound",
        "Call-ID": "at6dmu4ffk97vnlp6qfq",
        "Caller-ID-Name": "web phone",
        "Caller-ID-Number": "356",
        "Custom-Channel-Vars": {
            "Account-ID": "account0000000000000000000000002",
            "Account-Name": "wefwefwefwef",
            "Account-Realm": "wefwefwefwef.2600hz.com",
            "Application-Name": "callflow",
            "Application-Node": "kazoo_apps@wef.2600hz.com",
            "Authorizing-ID": "d509114b66efabf32dfd78dc464b46dd",
            "Authorizing-Type": "device",
            "Bridge-ID": "at6dmu4ffk97vnlp6qfq",
            "Caller-Privacy-Name": "false",
            "Caller-Privacy-Number": "false",
            "Channel-Authorized": "true",
            "Ecallmgr-Node": "ecallmgr@wef.2600hz.com",
            "Fetch-ID": "a60aea8c-67f2-11e5-8465-3390f8e3460f",
            "Global-Resource": "false",
            "Owner-ID": "699ed7e3d583e2577ac017c575f87262",
            "Realm": "wefwefwefwef.2600hz.com",
            "Register-Overwrite-Notify": "false",
            "Suppress-Unregister-Notifications": "false",
            "Username": "user_wpxnx7am9w"
        },
        "Custom-SIP-Headers": {
            "X-AUTH-IP": "192.168.25.203"
        },
        "Disposition": "ANSWER",
        "Duration-Seconds": "32",
        "Event-Category": "call_event",
        "Event-Name": "CHANNEL_DESTROY",
        "From": "356@wefwefwefwef.2600hz.com",
        "From-Tag": "l530ecbu2f",
        "From-Uri": "user_wpxnx7am9w@wefwefwefwef.2600hz.com",
        "Hangup-Cause": "NORMAL_CLEARING",
        "Media-Server": "wef.2600hz.com",
        "Msg-ID": "1443672788333353",
        "Node": "ecallmgr@wef.2600hz.com",
        "Presence-ID": "356@wefwefwefwef.2600hz.com",
        "Remote-SDP": "v=0\r\no=- 7274649247909803147 2 IN IP4 192.168.25.203\r\ns=-\r\nt=0 0\r\na=group:BUNDLE audio\r\na=msid-semantic: WMS CS9KeiNShVWxihCq6BmFZ7r1FrWsts6UfkcQ\r\nm=audio 49382 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 126\r\nc=IN IP4 192.168.25.203\r\na=rtpmap:111 opus/48000/2\r\na=fmtp:111 minptime=10; useinbandfec=1\r\na=rtpmap:103 ISAC/16000\r\na=rtpmap:104 ISAC/32000\r\na=rtpmap:9 G722/8000\r\na=rtpmap:0 PCMU/8000\r\na=rtpmap:8 PCMA/8000\r\na=rtpmap:106 CN/32000\r\na=rtpmap:105 CN/16000\r\na=rtpmap:13 CN/8000\r\na=rtpmap:126 telephone-event/8000\r\na=rtcp:59374 IN IP4 192.168.25.203\r\na=candidate:889533752 1 udp 2122265343 fde9:8246:57d3:df4f:8d39:2fa0:21a2:cc43 58565 typ host generation 0\r\na=candidate:2922620760 1 udp 2122194687 192.168.25.203 49382 typ host generation 0\r\na=candidate:889533752 2 udp 2122265342 fde9:8246:57d3:df4f:8d39:2fa0:21a2:cc43 49383 typ host generation 0\r\na=candidate:2922620760 2 udp 2122194686 192.168.25.203 59374 typ host generation 0\r\na=candidate:2072431048 1 tcp 1518285567 fde9:8246:57d3:df4f:8d39:2fa0:21a2:cc43 0 typ host tcptype active generation 0\r\na=candidate:3769654184 1 tcp 1518214911 192.168.25.203 0 typ host tcptype active generation 0\r\na=candidate:2072431048 2 tcp 1518285566 fde9:8246:57d3:df4f:8d39:2fa0:21a2:cc43 0 typ host tcptype active generation 0\r\na=candidate:3769654184 2 tcp 1518214910 192.168.25.203 0 typ host tcptype active generation 0\r\na=ice-ufrag:1tev3wX2bSa+rlLj\r\na=ice-pwd:a8xkPKpuvM99mnF4FriMxbkV\r\na=fingerprint:sha-256 F2:BC:FC:0A:9C:F5:7D:87:26:D1:8B:8F:7F:2E:AE:81:40:45:28:DD:51:2B:BD:08:44:EB:6B:69:3A:37:50:93\r\na=setup:actpass\r\na=mid:audio\r\na=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\na=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\r\na=rtcp-mux\r\na=maxptime:60\r\na=ssrc:376706195 cname:5rLP7HpPfGQdTezq\r\na=ssrc:376706195 msid:CS9KeiNShVWxihCq6BmFZ7r1FrWsts6UfkcQ 0ae35b40-7027-412e-91a9-563e853b53b5\r\na=ssrc:376706195 mslabel:CS9KeiNShVWxihCq6BmFZ7r1FrWsts6UfkcQ\r\na=ssrc:376706195 label:0ae35b40-7027-412e-91a9-563e853b53b5\r\na=oldmediaip:127.0.0.1\r\n",
        "Request": "*97@wefwefwefwef.2600hz.com",
        "Ringing-Seconds": "0",
        "Switch-URI": "sip:192.168.25.216:11000",
        "Switch-URL": "sip:mod_sofia@192.168.25.216:11000",
        "Timestamp": 63610891988,
        "To": "*97@wefwefwefwef.2600hz.com",
        "To-Tag": "9tr3FZcKDaNHK",
        "To-Uri": "*97@wefwefwefwef.2600hz.com",
        "User-Agent": "SIP.js/0.6.4"
    }
}
```

