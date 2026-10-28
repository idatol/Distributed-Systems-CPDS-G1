
-module(acceptor).
-export([start/2]).

start(Name, PanelId) ->
    spawn(fun() -> init(Name, PanelId) end).

init(Name, PanelId) ->
    {ok, Name} = pers:open(Name),

    {SavedPromised, SavedVoted, SavedValue, SavedPanelId} =
        pers:read(Name),

    ActualPanelId =
        case PanelId of
            na -> SavedPanelId;
            _  -> PanelId
        end,

    %% Save the panel ID only when supplied on a fresh start.
    %% Do not rewrite unchanged state after a restart.
    case PanelId of
        na -> ok;
        _  -> pers:store(
                  Name,
                  SavedPromised,
                  SavedVoted,
                  SavedValue,
                  ActualPanelId
              )
    end,

    Colour =
        case SavedValue of
            na -> {0, 0, 0};
            _  -> SavedValue
        end,

    ActualPanelId !
        {updateAcc,
         "Voted: " ++ lists:flatten(
             io_lib:format("~p", [SavedVoted])
         ),
         "Promised: " ++ lists:flatten(
             io_lib:format("~p", [SavedPromised])
         ),
         Colour},

    acceptor(
        Name,
        SavedPromised,
        SavedVoted,
        SavedValue,
        ActualPanelId
    ).

acceptor(Name, Promised, Voted, Value, PanelId) ->
    receive
        {prepare, Proposer, Round} ->
            case order:gr(Round, Promised) of
                true ->
                    %% Persist the promise before replying.
                    pers:store(Name, Round, Voted, Value, PanelId),

                    Proposer ! {promise, Round, Voted, Value},

                    io:format(
                        "[Acceptor ~w] Phase 1: promised ~w voted ~w colour ~w~n",
                        [Name, Round, Voted, Value]
                    ),

                    Colour =
                        case Value of
                            na -> {0, 0, 0};
                            _  -> Value
                        end,

                    PanelId !
                        {updateAcc,
                         "Voted: " ++ lists:flatten(
                             io_lib:format("~p", [Voted])
                         ),
                         "Promised: " ++ lists:flatten(
                             io_lib:format("~p", [Round])
                         ),
                         Colour},

                    acceptor(Name, Round, Voted, Value, PanelId);

                false ->
                    Proposer ! {sorry, {prepare, Round}},
                    acceptor(Name, Promised, Voted, Value, PanelId)
            end;

        {accept, Proposer, Round, Proposal} ->
            case order:goe(Round, Promised) of
                true ->
                    case order:goe(Round, Voted) of
                        true ->
                            %% Persist the vote before replying.
                            pers:store(
                                Name, Promised, Round, Proposal, PanelId
                            ),

                            Proposer ! {vote, Round},

                            io:format(
                                "[Acceptor ~w] Phase 2: promised ~w voted ~w colour ~w~n",
                                [Name, Promised, Round, Proposal]
                            ),

                            PanelId !
                                {updateAcc,
                                 "Voted: " ++ lists:flatten(
                                     io_lib:format("~p", [Round])
                                 ),
                                 "Promised: " ++ lists:flatten(
                                     io_lib:format("~p", [Promised])
                                 ),
                                 Proposal},

                            acceptor(
                                Name, Promised, Round, Proposal, PanelId
                            );

                        false ->
                            %% Lower than the last voted round:
                            %% reply without changing the saved state.
                            Proposer ! {sorry, {accept, Round}},
                            acceptor(Name, Promised, Voted, Value, PanelId)
                    end;

                false ->
                    Proposer ! {sorry, {accept, Round}},
                    acceptor(Name, Promised, Voted, Value, PanelId)
            end;

        stop ->
            PanelId ! stop,
            pers:close(Name),
            pers:delete(Name),
            ok
    end.
