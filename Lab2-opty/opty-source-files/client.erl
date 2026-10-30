-module(client).
-export([start/5]).

%% ORIGINAL:
%% start(ClientID, Entries, Reads, Writes, Server) ->
%%     spawn(fun() -> open(ClientID, Entries, Reads, Writes, Server, 0, 0) end).

%% PART 3 (vi): Entries is now the list of store indices this client accesses
start(ClientID, Entries, Reads, Writes, Server) ->
    spawn(fun() -> open(ClientID, list_to_tuple(Entries), Reads, Writes, Server, 0, 0) end).

open(ClientID, Entries, Reads, Writes, Server, Total, Ok) ->
    Server ! {open, self()},
    receive
        {stop, From} ->
            io:format("~w: Transactions TOTAL:~w, OK:~w, -> ~w % ~n",
            %% ORIGINAL: [ClientID, Total, Ok, 100*Ok/Total]),
            %% PART 3: max/2 avoids a crash when a client made no transactions
            [ClientID, Total, Ok, 100*Ok/max(1, Total)]),
            From ! {done, self()},
            ok;
        {transaction, Validator, Store} ->
            Handler = handler:start(self(), Validator, Store),
            case do_transaction(ClientID, Entries, Reads, Writes, Handler) of
                ok ->
                    open(ClientID, Entries, Reads, Writes, Server, Total+1, Ok+1);
                abort ->
                    open(ClientID, Entries, Reads, Writes, Server, Total+1, Ok)
            end
    end.

do_transaction(_, _, 0, 0, Handler) ->
    do_commit(Handler);
do_transaction(ClientID, Entries, 0, Writes, Handler) ->
    do_write(Entries, Handler, ClientID),
    do_transaction(ClientID, Entries, 0, Writes-1, Handler);
do_transaction(ClientID, Entries, Reads, 0, Handler) ->
    do_read(Entries, Handler),
    do_transaction(ClientID, Entries, Reads-1, 0, Handler);
do_transaction(ClientID, Entries, Reads, Writes, Handler) ->
    Op = rand:uniform(),
    if Op >= 0.5 ->
         do_read(Entries, Handler),
         do_transaction(ClientID, Entries, Reads-1, Writes, Handler);
       true -> 
         do_write(Entries, Handler, ClientID),
         do_transaction(ClientID, Entries, Reads, Writes-1, Handler)
    end.

do_read(Entries, Handler) ->
    Ref = make_ref(),
    %% ORIGINAL: Num = rand:uniform(Entries),
    %% PART 3 (vi): pick a random entry from this client's subset
    Num = element(rand:uniform(tuple_size(Entries)), Entries),
    Handler ! {read, Ref, Num},
    receive
        {value, Ref, Value} -> Value
    end.

do_write(Entries, Handler, Value) ->
    %% ORIGINAL: Num = rand:uniform(Entries),
    %% PART 3 (vi): pick a random entry from this client's subset
    Num = element(rand:uniform(tuple_size(Entries)), Entries),
    Handler ! {write, Num, Value}.

do_commit(Handler) ->
    Ref = make_ref(),
    Handler ! {commit, Ref},
    receive
        {Ref, Value} -> Value
    end.


    
