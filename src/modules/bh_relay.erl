%%%-----------------------------------------------------------------------------
%%% @copyright (C) 2012-2021, 2600Hz
%%% @doc
%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/.
%%%
%%% @end
%%%-----------------------------------------------------------------------------
-module(bh_relay).

-export([init/0
        ,authorize/2
        ,validate/2
        ,bindings/2
        ,authorize_broadcast/2
        ,validate_broadcast/2
        ,broadcast/2
        ]).

-include("blackhole.hrl").

-define(CATEGORY, <<"relay">>).

-define(RELAY_EVENTS
       ,[<<"conference">>
        ]).

-define(ACCOUNT_BINDING(AccountId, Event, Id)
       ,kz_binary:join([?CATEGORY, AccountId, Event, Id], <<".">>)
       ).

-define(BINDING(Event, Id)
       ,kz_binary:join([?CATEGORY, Event, Id], <<".">>)
       ).

-define(EVENT_BINDINGS(Id)
       ,lists:foldl(fun(Event, Acc) -> [?BINDING(Event, Id) | Acc] end, [], ?RELAY_EVENTS)
       ).

-define(ALL, <<"*">>).

-define(BROADCAST_REQ_VALUES, [{<<"Event-Category">>, <<"relay">>}
                              ,{<<"Event-Name">>, <<"broadcast">>}
                              ]).

-spec init() -> any().
init() ->
    init_bindings(),
    _ = blackhole_bindings:bind(<<"blackhole.events.authorize.relay">>, ?MODULE, 'authorize'),
    _ = blackhole_bindings:bind(<<"blackhole.events.validate.relay">>, ?MODULE, 'validate'),
    _ = blackhole_bindings:bind(<<"blackhole.events.bindings.relay">>, ?MODULE, 'bindings'),
    _ = blackhole_bindings:bind(<<"blackhole.authorize.relay.broadcast">>, ?MODULE, 'authorize_broadcast'),
    _ = blackhole_bindings:bind(<<"blackhole.validate.relay.broadcast">>, ?MODULE, 'validate_broadcast'),
    _ = blackhole_bindings:bind(<<"blackhole.command.relay.broadcast">>, ?MODULE, 'broadcast').

init_bindings() ->
    Bindings = ?EVENT_BINDINGS(<<"*">>),
    case kapps_config:set_default(?CONFIG_CAT, [<<"bindings">>, <<"relay">>], Bindings) of
        {'ok', _} -> lager:debug("initialized relay bindings");
        {'error', _E} -> lager:info("failed to initialize conference bindings: ~p", [_E])
    end.

-spec authorize(bh_context:context(), map()) -> bh_context:context().
authorize(Context, _) -> Context.

-spec validate(bh_context:context(), map()) -> bh_context:context().
validate(Context, #{keys := [?ALL]}) ->
    Context;
validate(Context, #{keys := [Event]}) ->
    case lists:member(Event, ?RELAY_EVENTS) of
        'false' ->
            bh_context:add_error(Context, <<"Unsupported relay event ",Event/binary>>);
        'true' -> Context
    end;
validate(Context, #{keys := Keys}) ->
    bh_context:add_error(Context, <<"invalid format for relay subscription : ", (kz_binary:join(Keys))/binary>>).

-spec bindings(bh_context:context(), map()) -> map().
bindings(Context, #{account_id := AccountId
                   ,keys := [Event]
                   }=Map) ->
    {ok, Claims} = kz_auth:validate_token(bh_context:auth_token(Context)),
    Id = kz_json:get_ne_binary_value(<<"id">>, Claims),
    Requested = ?BINDING(Event, Id),
    Subscribed = [?ACCOUNT_BINDING(AccountId, Event, Id)],
    Listeners = [{'amqp', 'bind', event_binding_options(AccountId, Event, Id)}],
    Map#{requested => Requested
        ,subscribed => Subscribed
        ,listeners => Listeners
        }.

-spec authorize_broadcast(bh_context:context(), kz_json:object()) -> bh_context:context().
authorize_broadcast(Context, _Payload) -> Context.

-spec validate_broadcast(bh_context:context(), kz_json:object()) -> bh_context:context().
validate_broadcast(Context, Payload) ->
    case broadcast_data(Payload) =:= undefined
        orelse broadcast_params(Payload) =:= undefined
    of
        true -> bh_context:add_error(Context, <<"missing required data object">>);
        false -> Context
    end.

-spec broadcast(bh_context:context(), kz_json:object()) -> bh_context:context().
broadcast(Context, Payload) ->
    JObj = kz_json:set_values(kz_api:default_headers(?APP_NAME, ?APP_VERSION), broadcast_set_session(Context, broadcast_params(Payload))),
    ServerId = kz_api:server_id(broadcast_data(Payload)),
    case publish_broadcast(ServerId, JObj) of
        ok -> bh_context:set_resp_status(Context, <<"success">>);
        {error, Error} -> bh_context:add_error(Context, Error)
    end.

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @doc
%% @end
%%------------------------------------------------------------------------------
-spec event_binding_options(kz_term:ne_binary(), kz_term:ne_binary(), kz_term:ne_binary()) -> kz_term:proplist().
event_binding_options(AccountId, Event, Id) ->
    [{'exchange', [{name, <<"live">>}, {type, <<"topic">>}]}
    ,{'routing', kz_binary:join([?CATEGORY, AccountId, Event, Id], <<".">>)}
    ,'federate'
    ].

broadcast_params(JObj) ->
    kz_json:get_json_value(<<"params">>, broadcast_data(JObj)).

broadcast_data(JObj) ->
    kz_json:get_json_value(<<"data">>, JObj).

broadcast_set_session(Context, JObj) ->
    {ok, Claims} = kz_auth:validate_token(bh_context:auth_token(Context)),
    Id = kz_json:get_ne_binary_value(<<"id">>, Claims),
    kz_json:set_value(<<"relay_id">>, Id, JObj).

-spec publish_broadcast(kz_term:api_ne_binary(), kz_json:object()) -> 'ok' | {error, any()}.
publish_broadcast(undefined, _API) ->
    {error, <<"no server_id to publish dialog">>};
publish_broadcast(ServerId, API) ->
    {'ok', Payload} = kz_api:prepare_api_payload(kz_json:set_values(?BROADCAST_REQ_VALUES, API), [], fun build/1),
    kz_amqp_util:targeted_publish(ServerId, Payload).

-spec build(kz_term:proplist()) -> kz_api:api_formatter_return().
build(Props) ->
    kz_api:build_message(Props, props:get_keys(Props), []).
