# Basic Troubleshooting

## I'm getting replies like "failed to authenticate token"

You need to provide a valid `auth_token` when sending request. Please use [Crossbar API](https://docs.2600hz.com/git/2600hz/kazoo-crossbar/doc/how_to_authenticate.md) (through HTTP protocol) to authenticate first an obtain an Auth Token and use that.

## I sent a websocket message but did not received any reply

You may have used a wrong `action` in the request. Please check that the action exists or its module is started on Blackhole server.

## "no available subscriptions to requested binding"

If you receiving this reply when trying to subscribe to an event, it is maybe:

* you have a typo in the binding name
* check the binding is correct
* the binding doesn't exists
* the module that provides that binding is not started on Blackhole server

Please check the available events for binding using Crossbar HTTP Websocket API. Or ask your system admin to check if the event module is started or not.

## I subscribed/binded to an event but not receiving anything

This could have multiple reason like:

* the event is not happened yet
* you subscribed to a wrong binding
* you may need a subscription to a more specific binding (`call.{CHANNEL_CREATE}.{CALL_ID}`)
* you may need a subscription to a more generic binding (`call.{CHANNEL_CREATE}.*`)
