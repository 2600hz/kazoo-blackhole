%%%-----------------------------------------------------------------------------
%%% @copyright (C) 2012-2021, 2600Hz
%%% @doc
%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/.
%%%
%%% @end
%%%-----------------------------------------------------------------------------
-module(bh_publish_app_event).

-export([init/0
        ,validate/2
        ,publish_event/2
        ,authorize/2
        ]).

-include("blackhole.hrl").

-spec init() -> 'ok'.
init() ->
    _ = blackhole_bindings:bind(<<"blackhole.authorize.publish_app_event">>, ?MODULE, 'authorize'),
    _ = blackhole_bindings:bind(<<"blackhole.validate.publish_app_event">>, ?MODULE, 'validate'),
    _ = blackhole_bindings:bind(<<"blackhole.command.publish_app_event">>, ?MODULE, 'publish_event'),
    'ok'.

-spec authorize(bh_context:context(), kz_json:object()) -> bh_context:context().
authorize(Context, Payload) ->
    Data = kz_json:get_ne_json_value(<<"data">>, Payload, kz_json:new()),
    authorize_account(Context, bh_context:is_authenticated(Context), account_id(Data, 'undefined')).

authorize_account(Context, 'false', _AccountId) ->
    bh_context:add_error(Context, <<"unauthorized">>);
authorize_account(Context, 'true', 'undefined') ->
    case bh_context:is_superduper_admin(Context) of
        'true' -> Context;
        'false' -> bh_context:add_error(Context, <<"unauthorized account id">>)
    end;
authorize_account(Context, 'true', AccountId) ->
    AuthAccountId = bh_context:auth_account_id(Context),
    case kzd_accounts:is_in_account_hierarchy(AuthAccountId, AccountId, 'true') of
        'true'  -> Context;
        'false' -> bh_context:add_error(Context, <<"unauthorized account id">>)
    end.

-spec validate(bh_context:context(), kz_json:object()) -> bh_context:context().
validate(Context, Payload) ->
    RequiredFields = [{<<"application">>, 'undefined', fun kz_term:is_ne_binary/1}
                     ,{<<"category">>, 'undefined', fun kz_term:is_ne_binary/1}
                     ,{<<"subcategory">>, 'undefined', fun kz_term:is_ne_binary/1}
                     ],
    validate(Context, Payload, RequiredFields).

validate(Context, Payload, []) ->
    EventData = kz_json:get_value([<<"data">>, <<"payload">>], Payload, kz_json:new()),
    case kz_json:is_json_object(EventData) of
        'true' -> Context;
        'false' -> bh_context:add_error(Context, <<"Field value did not matched type JSON: payload">>)
    end;
validate(Context, Payload, [{Field, DefaultValue, CheckFun} | RequiredFields]) ->
    Value = kz_json:get_value([<<"data">>, Field], Payload, DefaultValue),
    case CheckFun(Value) of
        'true' -> validate(Context, Payload, RequiredFields);
        'false' ->
            bh_context:add_error(Context, <<"Field is required but missing: ", Field/binary>>)
    end.

-spec publish_event(bh_context:context(), kz_json:object()) -> bh_context:context().
publish_event(Context, Payload) ->
    APIProp = event_payload(Context, kz_json:get_ne_json_value(<<"data">>, Payload, kz_json:new())),
    RoutingKey = kz_binary:join([props:get_ne_binary_value(<<"Application">>, APIProp)
                                ,props:get_ne_binary_value(<<"Account-ID">>, APIProp)
                                ,props:get_ne_binary_value(<<"Category">>, APIProp)
                                ,props:get_ne_binary_value(<<"Sub-Category">>, APIProp)
                                | props:get_value(<<"Subscriptions">>, APIProp, [])
                                ]
                               ,<<".">>
                               ),
    Binding = kz_binary:join([props:get_ne_binary_value(<<"Application">>, APIProp)
                             ,props:get_ne_binary_value(<<"Category">>, APIProp)
                             ,props:get_ne_binary_value(<<"Sub-Category">>, APIProp)
                             | props:get_value(<<"Subscriptions">>, APIProp, [])
                             ]
                            ,<<".">>
                            ),
    lager:debug("publishing app_event to ~s", [RoutingKey]),
    case kz_amqp_worker:cast(APIProp, fun kapi_websockets:publish_app_event/1) of
        'ok' ->
            RespData = kz_json:from_list([{<<"result">>, <<"sent">>}
                                         ,{<<"binding">>, Binding}
                                         ]
                                        ),
            bh_context:set_resp_data(Context, RespData);
        {'returned', _, BasicReturn} ->
            lager:debug("message got returned by broker: ~p", [BasicReturn]),
            bh_context:add_error(Context, <<"failed to sent the event to borker">>);
        {'error', _Error} ->
            lager:debug("failed to send message: ~p", [_Error]),
            bh_context:add_error(Context, <<"failed to sent the event">>)
    end.

-spec event_payload(bh_context:context(), kz_json:object()) -> kz_term:api_terms().
event_payload(Context, Data) ->
    [{<<"Account-ID">>, account_id(Data, bh_context:auth_account_id(Context))}
    ,{<<"Application">>, kz_json:get_ne_binary_value(<<"application">>, Data)}
    ,{<<"Category">>, kz_json:get_ne_binary_value(<<"category">>, Data)}
    ,{<<"Payload">>, kz_json:get_ne_json_value(<<"payload">>, Data, kz_json:new())}
    ,{<<"Sub-Category">>, kz_json:get_ne_binary_value(<<"subcategory">>, Data)}
    ,{<<"Subscriptions">>, subscriptions(Data)}
    | kz_api:default_headers(?APP_NAME, ?APP_VERSION)
    ].

-spec subscriptions(kz_json:object()) -> kz_term:ne_binaries().
subscriptions(Data) ->
    Subscription = kz_json:get_ne_binary_value(<<"subscription">>, Data),
    case kz_json:get_list_value(<<"subscriptions">>, Data, []) of
        [] when Subscription =/= 'undefined' -> Subscription;
        [] -> [];
        Subscriptions -> Subscriptions
    end.

-spec account_id(kz_json:object(), Default) -> kz_term:ne_binary() | Default.
account_id(Data, Default) ->
    kz_json:get_ne_binary_value(<<"account_id">>, Data, Default).
