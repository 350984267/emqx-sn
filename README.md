emqttd_sn
=========

MQTT-SN Gateway for The EMQTT Broker

Configure Plugin
----------------

File: etc/emqttd_sn.conf

```erlang
{listener, {1884, []}}.

```

## Usage

### simple 

examples/simple_example.erl

```erlang
%% create udp socket
{ok, Socket} = gen_udp:open(0, [binary]),

%% connect to emqttd_sn broker
Package = gen_connect_package(ClientId),
ok = gen_udp:send(Socket, ?HOST, ?PORT, Package),

%% register topic_id
RegisterPackage = gen_register_package(<<"TopicA">>, 1),
ok = gen_udp:send(Socket, ?HOST, ?PORT, RegisterPackage),

%% subscribe
SubscribePackage = gen_subscribe_package(1),
ok = gen_udp:send(Socket, ?HOST, ?PORT, SubscribePackage),

%% publish
PublishPackage = gen_publish_package(1, <<"Payload...">>),
ok = gen_udp:send(Socket, ?HOST, ?PORT, PublishPackage),

%% receive message
receive
    {udp, Socket, _, _, Bin} ->
        case Bin of
            <<_Len:8, ?SN_PUBLISH, _:1, _Flag:8, TopicId:16, MsgId:16, Data/binary>> ->
                io:format("recv publish Qos: ~p, TopicId: ~p, MsgId: ~p, Data: ~p~n", [Qos, TopicId, MsgId, Data]);
            _ ->
                ok
        end
after
    1000 ->
        io:format("Error: receive timeout!~n")
end,

%% disconnect from emqttd_sn broker
DisConnectPackage = gen_disconnect_package(),
ok = gen_udp:send(Socket, ?HOST, ?PORT, DisConnectPackage).

```

Load Plugin
-----------

```
./bin/emqttd_ctl plugins load emqttd_sn
```

License
-------

Apache License Version 2.0

Author
------

Feng Lee <feng@emqtt.io>
