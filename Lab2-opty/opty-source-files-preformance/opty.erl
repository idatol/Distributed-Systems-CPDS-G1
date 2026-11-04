-module(opty).
%% ORIGINAL: -export([start/5, stop/1]).
-export([start/5, start/6, stop/1]).

%% Clients: Number of concurrent clients in the system
%% Entries: Number of entries in the store
%% Reads: Number of read operations per transaction
%% Writes: Number of write operations per transaction
%% Time: Duration of the experiment (in secs)
%% Subset: Number of entries each client accesses (a random subset of the store)

%% ORIGINAL:
%% start(Clients, Entries, Reads, Writes, Time) ->
%%     register(s, server:start(Entries)),
%%     L = startClients(Clients, [], Entries, Reads, Writes),
%%     io:format("Starting: ~w CLIENTS, ~w ENTRIES, ~w RDxTR, ~w WRxTR, DURATION ~w s~n",
%%          [Clients, Entries, Reads, Writes, Time]),
%%     timer:sleep(Time*1000),
%%     stop(L).

%% PART 3 (vi): start/5 now uses the whole store (Subset = Entries)
start(Clients, Entries, Reads, Writes, Time) ->
    start(Clients, Entries, Reads, Writes, Time, Entries).

%% PART 3 (vi): each client accesses a random subset of Subset entries
start(Clients, Entries, Reads, Writes, Time, Subset) ->
    register(s, server:start(Entries)),
    L = startClients(Clients, [], Entries, Reads, Writes, Subset),
    io:format("Starting: ~w CLIENTS, ~w ENTRIES, ~w RDxTR, ~w WRxTR, ~w SUBSET, DURATION ~w s~n",
         [Clients, Entries, Reads, Writes, Subset, Time]),
    timer:sleep(Time*1000),
    stop(L).

stop(L) ->
    io:format("Stopping...~n"),
    stopClients(L),
    waitClients(L),
    s ! stop,
    io:format("Stopped~n").

%% ORIGINAL:
%% startClients(0, L, _, _, _) -> L;
%% startClients(Clients, L, Entries, Reads, Writes) ->
%%     Pid = client:start(Clients, Entries, Reads, Writes, s),
%%     startClients(Clients-1, [Pid|L], Entries, Reads, Writes).

%% PART 3 (vi): pass each client its own random subset of the store
startClients(0, L, _, _, _, _) -> L;
startClients(Clients, L, Entries, Reads, Writes, Subset) ->
    Pid = client:start(Clients, subset(Entries, Subset), Reads, Writes, s),
    startClients(Clients-1, [Pid|L], Entries, Reads, Writes, Subset).

%% Random, not necessarily contiguous, subset of S entries of the store
subset(Entries, S) ->
    lists:sublist([X || {_, X} <- lists:sort([{rand:uniform(), E} ||
                                               E <- lists:seq(1, Entries)])], S).

stopClients([]) ->
    ok;
stopClients([Pid|L]) ->
    Pid ! {stop, self()},	
    stopClients(L).

waitClients([]) ->
    ok;
waitClients(L) ->
    receive
        {done, Pid} ->
            waitClients(lists:delete(Pid, L))
    end.
