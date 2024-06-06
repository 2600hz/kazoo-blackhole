# Overview

Receive Call related events.

## Bindings

Replace `{CALL_ID}` with the actual Call-ID of a call (if known), or use `*` to receive the events for all calls.

* `call.CHANNEL_CREATE.{CALL_ID}`
* `call.CHANNEL_ANSWER.{CALL_ID}`
* `call.CHANNEL_DESTROY.{CALL_ID}`
* `call.CHANNEL_HOLD.{CALL_ID}`
* `call.CHANNEL_UNHOLD.{CALL_ID}`
* `call.CHANNEL_BRIDGE.{CALL_ID}`
* `call.PARK_PARKED.{CALL_ID}`
* `call.PARK_RETRIEVED.{CALL_ID}`
* `call.PARK_ABANDONED.{CALL_ID}`

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

