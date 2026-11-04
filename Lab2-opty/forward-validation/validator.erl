-module(validator).
-export([start/0]).

%% Forward validation validator.

start() ->
    spawn_link(fun() -> init() end).

init()->
    validator().

validator() ->
    receive
        {validate, Ref, TxId, Reads, Writes, Client} ->
            Tag = make_ref(),
            WEntries = [Entry || {_, Entry, _} <- Writes],
            send_write_checks(WEntries, TxId, Tag),
            case check_writes(length(WEntries), Tag, ok) of
                ok ->
                    update(Writes, Tag),
                    release(Reads, TxId),
                    Client ! {Ref, ok};
                abort ->
                    unlock(WEntries, Tag),
                    release(Reads, TxId),
                    Client ! {Ref, abort}
            end,
            validator();
        stop ->
            ok;
        _Old ->
            validator()
    end.

update(Writes, Tag) ->
    lists:foreach(fun({_, Entry, Value}) ->
                  Entry ! {write, Tag, Value}
                  end,
                  Writes).

unlock(WEntries, Tag) ->
    lists:foreach(fun(Entry) -> Entry ! {unlock, Tag} end, WEntries).


release(Reads, TxId) ->
    lists:foreach(fun(Entry) -> Entry ! {release, TxId} end, Reads).

send_write_checks(WEntries, TxId, Tag) ->
    Self = self(),
    lists:foreach(fun(Entry) ->
                  Entry ! {check, Tag, TxId, Self}
                  end,
                  WEntries).

%% Collect ALL replies (no early exit)
check_writes(0, _, Result) ->
    Result;
check_writes(N, Tag, Result) ->
    receive
        {Tag, ok} ->
            check_writes(N-1, Tag, Result);
        {Tag, abort} ->
            check_writes(N-1, Tag, abort)
    end.
