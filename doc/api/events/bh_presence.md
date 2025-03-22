# Presence

Receive SIP presence related Events.

## Bindings

Replace `{CALL_ID}` with the actual Call-ID of a call (if known), or use `*` to receive the events for all calls.
Replace `{USER}` with SIP username or use `*` as wild-card to receive all.

* `dialog.{CALL_ID}`
* `mwi_updates.{USER}`
* `update.{CALL_ID}`
