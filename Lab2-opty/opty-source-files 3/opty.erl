-module(opty).
-export([start/5, start/6, stop/1, start_server/1]).

-define(COOKIE, opty123).

%% Server node on the same host as this client node (whatever the hostname is)
start(Clients, Entries, Reads, Writes, Time) ->
    [_, Host] = string:split(atom_to_list(node()), "@"),
    ServerNode = list_to_atom("opty-srv@" ++ Host),
    start(Clients, Entries, Reads, Writes, Time, ServerNode).

%% Explicit server node, e.g. 'opty-srv@other-machine'
start(Clients, Entries, Reads, Writes, Time, ServerNode) ->
    true = erlang:set_cookie(node(), ?COOKIE),
    case net_adm:ping(ServerNode) of
        pong ->
            ok;
        pang ->
            exit({server_node_unreachable, ServerNode})
    end,
    {ok, _Pid} = rpc:call(ServerNode, opty, start_server, [Entries]),
    L = startClients(Clients, [], Entries, Reads, Writes,
                     {s, ServerNode}),
    io:format(
        "Starting: ~w CLIENTS, ~w ENTRIES, ~w RDxTR, ~w WRxTR, DURATION ~w s~n",
        [Clients, Entries, Reads, Writes, Time]
    ),
    timer:sleep(Time * 1000),
    stop({L, ServerNode}).

%% Runs on the server node. Always starts a fresh server:
%% if an old one is still registered (e.g. from a crashed run), stop it first.
start_server(Entries) ->
    case whereis(s) of
        undefined ->
            ok;
        Old ->
            Ref = monitor(process, Old),
            Old ! stop,
            receive
                {'DOWN', Ref, process, Old, _} -> ok
            end
    end,
    Pid = server:start(Entries),
    true = register(s, Pid),
    {ok, Pid}.


stop({L, ServerNode}) ->
    io:format("Stopping...~n"),
    stopClients(L),
    waitClients(L),
    rpc:call(ServerNode, erlang, send, [s, stop]),
    io:format("Stopped~n"),
    ok;
stop(L) when is_list(L) ->
    [_, Host] = string:split(atom_to_list(node()), "@"),
    stop({L, list_to_atom("opty-srv@" ++ Host)}).

stopClients([]) ->
    ok;
stopClients([Pid | L]) ->
    Pid ! {stop, self()},
    stopClients(L).

waitClients([]) ->
    ok;
waitClients(L) ->
    receive
        {done, Pid} ->
            waitClients(lists:delete(Pid, L))
    end.

startClients(0, L, _, _, _, _) ->
    L;
startClients(Clients, L, Entries, Reads, Writes, Server) ->
    Pid = client:start(Clients, Entries, Reads, Writes, Server),
    startClients(Clients - 1, [Pid | L], Entries, Reads, Writes, Server).