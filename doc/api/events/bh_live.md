# Overview

Receive Live Conference (verto?) related events.

## Authorization

Your Auth Token needs to have `live:all` or `live.conference` scope to access these events. Assign these scopes to users.

## Bindings

Replace `{CALL_ID}` with the actual Call-ID of a call (if known), or use `*` to receive the events for all calls.
Replace `{CONFERENCE_ID}` with the actual Conference-ID (if known), or use `*` to receive the events for all conferences.

* `live.conference.{CONFERENCE_ID}.{CALL_ID}.setup`
* `live.conference.{CONFERENCE_ID}.{CALL_ID}.chat`
* `live.conference.{CONFERENCE_ID}.{CALL_ID}.info`
* `live.conference.{CONFERENCE_ID}.{CALL_ID}.caption`
* `live.conference.{CONFERENCE_ID}.{CALL_ID}.broadcast`
* `live.conference.{CONFERENCE_ID}.{CALL_ID}.array`
