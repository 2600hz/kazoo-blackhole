# Publish WebSocket Application Events

This API provide a way publish an event to all WebSocket clients that are subscribed to this event. In some sort, this makes it possible so that a WebSocket application can send messages to all of its instances using Blackhole.

The `app_event` is published through KAZOO AMQP message bus to all Blackhole instances. This AMQP message is name spaced.

A WebSocket client can subscribe to this event using `subscribe` action to receives these events. The binding strings for subscription is up to the WebSocket application specification.

To receive this event one can [subscribe](./bh_events.md) to [`app_event` event](../events/bh_app_event.md).

## Request Payload

Key | Description | Type | Default | Required
--- | ----------- | ---- | ------- | --------
`action` | to publish `app_event` | `string('publish_app_event')` |  | `true`
`data.account_id` | The account ID to use | `string()` |  | `false`
`data.application` | the `application` part of routing key | `string()` |  | `true`
`data.category` | the `category` part of routing key | `string()` |  | `true`
`data.payload` | a payload to send alongside the event | `object()` | {} | `false`
`data.subcategory` | the `subcategory` part of routing key | `string()` |  | `true`
`data.subscription` | A Binding string to append to routing key | `string()` |  | `false`

For example:

```json
{
    "action": "publish_app_event",
    "auth_token": "{AUTH_TOKEN}",
    "request_id": "{REQUEST_ID}",
    "data": {
        "account_id": "156e05e8a12fd138540cd2017a97e371",
        "application": "mychatapp",
        "category": "room",
        "payload": {
            "message_body": "Anybody home?",
            "created_at": "2020-12-25 01:00:00"
        },
        "subcategory": "123",
        "subscription": "messages"
    }
}
```

This will get sent the data object as a event to anyone who subscribed to `app_event.mychatapp.156e05e8a12fd138540cd2017a97e371.room.123.messages` event.
