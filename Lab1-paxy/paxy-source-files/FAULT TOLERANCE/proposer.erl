-module(proposer).
-export([start/6]).

-define(timeout, 2000).
-define(backoff, 10).

start(Name, Proposal, Acceptors, Sleep, PanelId, Main) ->
    spawn(fun() ->
        init(Name, Proposal, Acceptors, Sleep, PanelId, Main)
    end).

init(Name, Proposal, Acceptors, Sleep, PanelId, Main) ->
    timer:sleep(Sleep),
    Begin = erlang:monotonic_time(),
    Round = order:first(Name),
    {Decision, LastRound} =
        round(Name, ?backoff, Round, Proposal, Acceptors, PanelId),
    End = erlang:monotonic_time(),
    Elapsed = erlang:convert_time_unit(
        End - Begin, native, millisecond
    ),
    io:format(
        "[Proposer ~w] DECIDED ~w in round ~w after ~w ms~n",
        [Name, Decision, LastRound, Elapsed]
    ),
    Main ! done,
    PanelId ! stop.

round(Name, Backoff, Round, Proposal, Acceptors, PanelId) ->
    io:format(
        "[Proposer ~w] Phase 1: round ~w proposal ~w~n",
        [Name, Round, Proposal]
    ),
    PanelId ! {
        updateProp,
        "Round: " ++ io_lib:format("~p", [Round]),
        Proposal
    },
    case ballot(Name, Round, Proposal, Acceptors, PanelId) of
        {ok, Value} ->
            {Value, Round};
        abort ->
            timer:sleep(rand:uniform(Backoff)),
            Next = order:inc(Round),
            round(
                Name, 2 * Backoff, Next,
                Proposal, Acceptors, PanelId
            )
    end.

ballot(Name, Round, Proposal, Acceptors, PanelId) ->
    prepare(Round, Acceptors),
    Quorum = (length(Acceptors) div 2) + 1,
    MaxSorry = length(Acceptors) - Quorum,
    MaxVoted = order:null(),
    case collect(
        Quorum, Round, MaxVoted, Proposal, 0, MaxSorry
    ) of
        {accepted, Value} ->
            io:format(
                "[Proposer ~w] Phase 2: round ~w proposal ~w (was ~w)~n",
                [Name, Round, Value, Proposal]
            ),
            PanelId ! {
                updateProp,
                "Round: " ++ io_lib:format("~p", [Round]),
                Value
            },
            accept(Round, Value, Acceptors),
            case vote(Quorum, Round, 0, MaxSorry) of
                ok ->
                    {ok, Value};
                abort ->
                    abort
            end;
        abort ->
            abort
    end.

prepare(Round, Acceptors) ->
    Fun = fun(Acceptor) ->
        send(Acceptor, {prepare, self(), Round})
    end,
    lists:foreach(Fun, Acceptors).

accept(Round, Proposal, Acceptors) ->
    Fun = fun(Acceptor) ->
        send(Acceptor, {accept, self(), Round, Proposal})
    end,
    lists:foreach(Fun, Acceptors).

send(Name, Message) ->
    if is_tuple(Name) -> %% remote
           Name ! Message;
       true -> %% local
           case whereis(Name) of
               undefined ->
                   down;
               Pid ->
                   Pid ! Message
           end
    end.

collect(0, _, _, Proposal, _, _) ->
    {accepted, Proposal};
collect(N, Round, MaxVoted, Proposal, Sorry, MaxSorry) ->
    receive
        {promise, Round, _, na} ->
            collect(
                N - 1, Round, MaxVoted, Proposal, Sorry, MaxSorry
            );

        {promise, Round, Voted, Value} ->
            case order:gr(Voted, MaxVoted) of
                true ->
                    collect(
                        N - 1, Round, Voted, Value, Sorry, MaxSorry
                    );
                false ->
                    collect(
                        N - 1, Round, MaxVoted, Proposal,
                        Sorry, MaxSorry
                    )
            end;

        {promise, _, _, _} ->
            collect(
                N, Round, MaxVoted, Proposal, Sorry, MaxSorry
            );

        {sorry, {prepare, Round}} ->
            case Sorry + 1 > MaxSorry of
                true ->
    abort;
                false ->
                    collect(
                        N, Round, MaxVoted, Proposal,
                        Sorry + 1, MaxSorry
                    )
            end;

        {sorry, _} ->
            collect(
                N, Round, MaxVoted, Proposal, Sorry, MaxSorry
            )
    after ?timeout ->
        abort
    end.

vote(0, _, _, _) ->
    ok;
vote(N, Round, Sorry, MaxSorry) ->
    receive
        {vote, Round} ->
            vote(N - 1, Round, Sorry, MaxSorry);

        {vote, _} ->
            vote(N, Round, Sorry, MaxSorry);

        {sorry, {accept, Round}} ->
            case Sorry + 1 > MaxSorry of
                true ->
    abort;
                false ->
                    vote(N, Round, Sorry + 1, MaxSorry)
            end;

        {sorry, _} ->
            vote(N, Round, Sorry, MaxSorry)
    after ?timeout ->
        abort
    end.