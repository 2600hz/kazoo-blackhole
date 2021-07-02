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
