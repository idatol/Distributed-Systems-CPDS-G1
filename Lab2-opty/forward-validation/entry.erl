-module(entry).
-export([new/1]).

%% Forward validation entry.


new(Value) ->
    spawn_link(fun() -> init(Value) end).

init(Value) ->
    entry(Value, []).

entry(Value, Readers) ->
    receive
        {read, Ref, From} ->
            From ! {Ref, self(), Value},
            entry(Value, add(From, Readers));
        {check, Tag, TxId, From} ->
            case lists:delete(TxId, Readers) of
                [] -> From ! {Tag, ok};
                _  -> From ! {Tag, abort}
            end,
            %% freeze the entry until the validator decides (write or unlock)
            locked(Value, Readers, Tag);
        {release, TxId} ->
            %% transaction finished
            entry(Value, lists:delete(TxId, Readers));
        stop ->
            ok
    end.


locked(Value, Readers, Tag) ->
    receive
        {write, Tag, New} ->
            entry(New, Readers);
        {unlock, Tag} ->
            entry(Value, Readers);
        stop ->
            ok
    end.

add(Tx, Readers) ->
    case lists:member(Tx, Readers) of
        true  -> Readers;
        false -> [Tx|Readers]
    end.
