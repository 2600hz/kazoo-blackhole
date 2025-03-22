# Subscribe to real-time events

This API provide a way to subscribe to receive real-time event using binding and
receive them on WebSocket message in real time. Effectively this API provides an
AMQP->WebSocket bridge, providing you with real-time event streams about calls,
API changes, and more.

## Authorization

Some events may need to check if you are authorized to access to event binding or not, please check the event documentation for more info.

## Request Payload

This is common a request to either `subscribe` or `unsubscribe` actions.

See [Binding string syntax](#binding-string-syntax) below to learn about the format of binding string.

| Key               | Description                       | Type                                   | Default | Required |
| ----------------- | --------------------------------- | -------------------------------------- | ------- | -------- |
| `action`          | to subscribe or unsubscribe       | `string('subscribe' \| 'unsubscribe')` |         | `true`   |
| `data.account_id` | The account ID to use for binding | `string()`                             |         | `false`  |
| `data.binding`    | Binding string to use             | `string()`                             |         | `false`  |
| `data.bindings`   | A list of bindings to use         | `array(string())`                      |         | `true`   |

Please note:

* If no `data.account_id` is present, the `account_id` from your `auth_token` will be used instead.
* `data.binding` will be picked first over `data.bindings` in case both are present.

## List of events

* [`call`](../events/bh_call.md)
* [`conference`](../events/bh_conference.md)
* [`fax`](../events/bh_fax.md)
* [`live`](../events/bh_live.md)
* [`object`](../events/bh_object.md)
* [`presence`](../events/bh_presence.md)

!!! note:
    You can get a list of available events and their bindings using Crossbar HTTP API [`GET /v2/websockets`](https://docs.2600hz.com/git/2600hz/kazoo-crossbar/doc/websockets.md#available-websocket-bindings).

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

After you subscribe to events the Blackhole application will listen for those events from AMQP. It will send an event to you through WebSocket if there is an active binding that matches this event.

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

The binding syntax is the same used throughout all {% BRAND_NAME %}, since it is the same as AMQP binding syntax.

Each binding is consist of multiple slots (or segments) separated by dot `.`, like `call.CHANNEL_CREATE.*`. Each slot is matches one slot in the event's routing key.

The are two special characters:

* `*` in a slot matches exactly one slot with any value
* `#` in a slot matches zero or more slots with any value

Here are some examples:

* `call.CHANNEL_CREATE.123qweasdzxc` will matches call's `CHANNEL_CREATE` event with Call-ID `123qweasdzxc`.
* `call.CHANNEL_CREATE.*` will matches all call's `CHANNEL_CREATE` events (with any Call-ID)

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
