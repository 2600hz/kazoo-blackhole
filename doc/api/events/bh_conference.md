# Overview

Receive conference related events.

## Authorization

Binding to all Conference-ID requires superduper admin access.

## Bindings

Replace `{CALL_ID}` with the actual Call-ID of a call (if known), or use `*` to receive the events for all conferences.
Replace `{CONFERENCE_ID}` with the actual Conference-ID (if known), or use `*` to receive the events for all conferences.

* `conference.command.{CONFERENCE_ID}`
* `conference.event.undeaf-member.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.deaf-member.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.unmute-member.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.mute-member.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.start-talking.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.stop-talking.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.del-member.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.add-member.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.unlock.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.lock.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.conference-destroy.{CONFERENCE_ID}.{CALL_ID}`
* `conference.event.conference-create.{CONFERENCE_ID}.{CALL_ID}`

For other events that are not specified here use a wild-card:

* `conference.event.*.{CONFERENCE_ID}.{CALL_ID}`

See Freeswitch [`mod_conference`](https://freeswitch.org/confluence/display/FREESWITCH/mod_conference) to see all possible events.
