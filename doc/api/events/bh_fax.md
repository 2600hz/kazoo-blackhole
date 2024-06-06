# Overview

Receive fax related events.

## Bindings

* `fax.status.{FAX_ID}`: Listen to status of Fax transmissions. Replace `{FAX_ID}` with Fax-ID or `*`.
* `fax.object.{ACTION}`: Listen to changes to Fax documents. Alternativly you can use [`object`](./bh_object.md). The `{ACTION}` is same as action for `object`: `doc_created`, `doc_edited` and `doc_deleted`.
