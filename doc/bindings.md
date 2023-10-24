
# Blackhole *Real-time HTTP Websocket Events*

### Binding to events

The binding syntax is the same used throughout all Crossbar applications, since it is the same as AMQP's binding syntax.

Here are a non-exhaustive list of bindings provided per default callback module:
* `bh_call`:
    * `call.CHANNEL_CREATE.*`
    * `call.CHANNEL_ANSWER.*`
    * `call.CHANNEL_DESTROY.*`
    * `call.CHANNEL_BRIDGE.*`
* `bh_conference`:
    * `conference.event.*.*`
    * `conference.command.*`
* `bh_fax`:
    * `fax.status.*`

### Writing your own bindings

Blackhole [callback modules](../src/modules) provide bindings to Kazoo events.
If however you do not find a callback module that provides the bindings you are looking for, you can easily add your own!

1. Copy [`bh_skel`](../../skel/src/integration/bh_skel.erl) into `bh_mymodule.erl`
2. Make sure the module name is prefixed by `bh_`
3. Now to make it listen to the events you want:
    * Your Blackhole callback module has to export the following functions:
        1. `init/0`
            * Called when the Blackhole module is started
            * Binds for the other following callback functions
        2. `validate/2`
            * Validates that a binding subscription is formatted correctly
        3. `bindings/2`
            * Provides the AMQP bindings that were requested by the subscription to the Blackhole AMQP listener
            * The bindings are added when the Blackhole module starts
            * And removed when it stops
