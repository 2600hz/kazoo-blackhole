# Overview

Receive event published by other WebSocket applications.

This is receiving end, to publish use [`publish_app_event`](../actions/bh_publish_app_event.md).

## Bindings

The binding is arbitrary and is up to the WebScoket applications.

The are 3 required parts (actually 4 if you consider `account_id` too):

* `application`
* `category`
* `subcategory`

The optional parts are to make this event more specific.

Examples:

* `myapp.event.user_portal`
* `myapp.event.user_portal.fax.sent`
* `myapp.event.cluster_manager.jobs.trigger.version_check`
* `myapp.event.webphone.quick_share.request.user.123456789`
* `myapp.event.webphone.quick_share.reply.123456789`
* `myapp.event.chat.123456789`
* `myapp.event.chat.123456789.broadcast`
* `myapp.event.chat.123456789.direct`


## Subscribe example

```json
{
    "action": "subscribe",
    "auth_token": "{AUTH_TOKEN}",
    "request_id": "{REQUEST_ID}",
    "data": {
        "account_id": "156e05e8a12fd138540cd2017a97e371",
        "binding": "myapp.event.cluster_manager.jobs.trigger.version_check"
    }
}
```
