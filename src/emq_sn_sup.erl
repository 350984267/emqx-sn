%%--------------------------------------------------------------------
%% Copyright (c) 2016-2017 Feng Lee <feng@emqtt.io>. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emq_sn_sup).

-author("Feng Lee <feng@emqtt.io>").

-behaviour(supervisor).

-export([start_link/3, init/1]).

-define(CHILD(I), {I, {I, start_link, []}, permanent, 5000, worker, [I]}).

start_link(Listener, Duration, GwId) ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, [Listener, Duration, GwId]).

init([{Port, Opts}, Duration, GwId]) ->

    BcSrv = {emq_sn_broadcast,
                {emq_sn_broadcast, start_link, [[Duration, GwId]]},
                    permanent, brutal_kill, worker, [emq_sn_broadcast]},

    GwSup = {emq_sn_gateway_sup,
              {emq_sn_gateway_sup, start_link, []},
                permanent, infinity, supervisor, [emq_sn_gateway_sup]},

    MFA = {emq_sn_gateway_sup, start_gateway, [GwId]},

    UdpSrv = {emq_sn_udp_server,
               {esockd_udp, server, [mqtt_sn, Port, Opts, MFA]},
                 permanent, 5000, worker, [esockd_udp]},

    {ok, { {one_for_all, 10, 3600}, [BcSrv, ?CHILD(emq_sn_registry), GwSup, UdpSrv] }}.

