%%%-----------------------------------------------------------------------------
%%% @copyright (C) 2012-2022, 2600Hz
%%% @doc
%%% @author James Aimonetti
%%% @author Peter Defebvre
%%% @author Ben Wann
%%% @author Roman Galeev
%%%
%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/.
%%%
%%% @end
%%%-----------------------------------------------------------------------------
-module(bh_app_event).

-export([init/0
        ,authorize/2
        ,validate/2
        ,bindings/2
        ]).

-include("blackhole.hrl").

-define(ALL, <<"*">>).


-spec init() -> any().
init() ->
    init_bindings(),
    _ = blackhole_bindings:bind(<<"blackhole.events.authorize.app_event">>, ?MODULE, 'authorize'),
    _ = blackhole_bindings:bind(<<"blackhole.events.validate.app_event">>, ?MODULE, 'validate'),
    blackhole_bindings:bind(<<"blackhole.events.bindings.app_event">>, ?MODULE, 'bindings').

init_bindings() ->
    Bindings = [binding_key([<<"{APPLICATION}">>, <<"{CATEGORY}">>, <<"{SUBCATEGORY}">>])],
    case kapps_config:set_default(?CONFIG_CAT, [<<"bindings">>, <<"app_event">>], Bindings) of
        {'ok', _} -> lager:debug("initialized app_event bindings");
        {'error', _E} -> lager:info("failed to initialize app_event bindings: ~p", [_E])
    end.

-spec authorize(bh_context:context(), map()) -> bh_context:context().
authorize(Context, _) -> Context.

-spec validate(bh_context:context(), map()) -> bh_context:context().
validate(Context, #{keys := [_Application, _Category, _SubCategory | _]}) ->
    Context;
validate(Context, #{keys := Keys}) ->
    bh_context:add_error(Context, <<"invalid format for app_event subscription: ", (kz_binary:join(Keys))/binary>>).

-spec bindings(bh_context:context(), map()) -> map().
bindings(_Context, #{account_id := AccountId
                    ,keys := [Application, Category, SubCategory | Subscription] = Binding
                    }=Map) ->
    Requested = binding_key(Binding),
    Subscribed = [kapi_websockets:create_app_event_key(Application, AccountId, Category, SubCategory, Subscription)],
    Listeners = [{'amqp', 'websockets', event_binding_options(Application, AccountId, Category, SubCategory, Subscription)}],
    Map#{requested => Requested
        ,subscribed => Subscribed
        ,listeners => Listeners
        }.

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @doc
%% @end
%%------------------------------------------------------------------------------
-spec binding_key(kz_term:ne_binaries()) -> kz_term:ne_binary().
binding_key(Binding) ->
    kz_binary:join([<<"app_event">> | Binding], <<".">>).

-spec event_binding_options(kz_term:ne_binary(), kz_term:ne_binary(), kz_term:ne_binary(), kz_term:ne_binary(), list()) -> kz_term:proplist().
event_binding_options(Application, AccountId, Category, SubCategory, Subscriptions) ->
    [{'restrict_to', [{'app_event', [{'application', Application}
                                    ,{'account_id', AccountId}
                                    ,{'category', Category}
                                    ,{'subcategory', SubCategory}
                                    ,{'subscriptions', Subscriptions}
                                    ]
                      }]
     }
    ,'federate'
    ].
