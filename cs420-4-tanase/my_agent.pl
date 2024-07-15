% Friday 19 April 2024 11:13:00 PM CDT
% Wumpus World
% Usage:
% consult('wumpus_world.pl').
% consult('my_agent.pl').
% initialize(fig72, Percept).
% wumpus:evaluate_agent(1,Score,Time).

% By: David Tanase

%   this procedure requires the external definition of two procedures:
%
%     init_agent: called after new world is initialized.  should perform
%                 any needed agent initialization.
%
%     run_agent(percept,action): given the current percept, this procedure
%                 should return an appropriate action, which is then
%                 executed.
%
% This is what should be fleshed out

:- use_module(wumpus_world).

:- dynamic([
    pit/2,
    wumpus/2,
    gold/2,
    visited/1,
    location/1,
    safe/1,
    has_gold/1,
    orientation/1,
    world_size/1,
    arc/3,
    wumpus_arc/3,
    arrow/1,
    shoot_position/1,
    shoot_orientation/1,
    critical_zone/1,
    confirmed_wumpus/1,
    wumpus_dead/1
]).

init_agent:-
  retractall(pit(_, _)),
  retractall(wumpus(_, _)),
  retractall(gold(_, _)),
  retractall(visited(_)),
  retractall(location(_)),
  retractall(safe(_)),
  retractall(has_gold(_)),
  retractall(orientation(_)),
  retractall(world_size(_)),
  retractall(arc(_, _, _)),
  retractall(wumpus_arc(_, _, _)),
  retractall(arrow(_)),
  retractall(shoot_position(_)),
  retractall(shoot_orientation(_)),
  retractall(confirmed_wumpus(_)),
  retractall(critical_zone(_)),
  retractall(wumpus_dead(_)),
  assert(safe([1, 1])),
  assert(location([1, 1])),
  assert(orientation(0)),
  assert(has_gold(0)),
  assert(visited([1, 1])),
  assert(arrow(1)),
  assert(world_size(4)),
  assert(wumpus_dead(0)),
  format('\n=====================================================\n'),
  format('This is init_agent:\n\tIt gets called once, use it for your initialization\n\n'),
  format('=====================================================\n\n').

%run_agent(Percept,Action):-
%run_agent(_, goforward):-
%  format('\n=====================================================\n'),
%  format('This is run_agent(.,.):\n\t It gets called each time step.\n\tThis default one simply moves forward\n'),
%  format('You might find "display_world" useful, for your debugging.\n'),
%  display_world,   
%  format('=====================================================\n\n').

run_agent([Stench, Breeze, Glitter, _, Scream], Action) :-
  format('\n=====================================================\n'),
  format('This is run_agent(.,.):\n\t It gets called each time step.\n'),
  display_world,
  format('Percept received: Stench=~w, Breeze=~w, Glitter=~w, Scream=~w\n', [Stench, Breeze, Glitter, Scream]),
  update_knowledgebase(Stench, Breeze, Glitter, Scream),
  format('Updated Knowledgebase\n'),
  query_knowledgebase(Action),
  format('Queried Knowledgebase for action\n'),
  update_agent(Action),
  format('Action chosen: ~w\n', Action),
  format('=====================================================\n\n'). 

update_agent(Action) :-
  (	Action == goforward	->	ua_forward;
    Action == turnleft 	->	ua_left;
		Action == turnright ->	ua_right;
		Action == grab  ->  ua_grab;
    Action == shoot ->  ua_shoot;
    true
	).

ua_forward :-
    location([X, Y]),
    X1 is X + 1,
    X2 is X - 1,
    Y1 is Y + 1,
    Y2 is Y - 1,
    orientation(Angle),
    retractall(location([X, Y])),
    ( Angle == 0  ->	assert(location([X1,Y])), assert(visited([X1,Y])), safe_location([X1,Y]);
  	  Angle == 90 ->  assert(location([X,Y1])), assert(visited([X,Y1])), safe_location([X,Y1]); 
      Angle == 180	->	assert(location([X2,Y])), assert(visited([X2,Y])), safe_location([X2,Y]); 
      Angle == 270	->	assert(location([X,Y2])), assert(visited([X,Y2])), safe_location([X,Y2])
    ).

ua_left :-
  orientation(Angle),
	(	  Angle == 0  ->	retractall(orientation(_)), assert(orientation(90));
  		Angle == 90	->	retractall(orientation(_)), assert(orientation(180));
  		Angle == 180	->	retractall(orientation(_)), assert(orientation(270));
  		Angle == 270	->	retractall(orientation(_)), assert(orientation(0))
  ).

ua_right :-
  orientation(Angle),
	(	  Angle == 0  ->	retractall(orientation(_)), assert(orientation(270));
  		Angle == 90	->	retractall(orientation(_)), assert(orientation(0));
  		Angle == 180	->	retractall(orientation(_)), assert(orientation(90));
  		Angle == 270	->	retractall(orientation(_)), assert(orientation(180))
  ).

ua_grab :-
  assert(has_gold(1)),
  retractall(gold(yes, _)).

ua_shoot :-
  retractall(arrow(_)),
  assert(arrow(0)),
  location([X, Y]),
  orientation(Angle),
  assert(shoot_position([X, Y])),
  assert(shoot_orientation(Angle)),
  X1 is X + 1,
  X2 is X - 1,
  Y1 is Y + 1,
  Y2 is Y - 1,
  (
    Angle == 0 -> format('crit zone at [~w,~w]\n', [X1, Y]), assert(critical_zone([X1, Y]));
    Angle == 90 -> format('crit zone at [~w,~w]\n', [X, Y1]), assert(critical_zone([X, Y1]));
    Angle == 180 -> format('crit zone at [~w,~w]\n', [X2, Y]), assert(critical_zone([X2, Y]));
    Angle == 270 -> format('crit zone at [~w,~w]\n', [X, Y2]), assert(critical_zone([X, Y2]));
    true
  ).

update_knowledgebase(Stench, Breeze, Glitter, Scream) :-
  update_stench(Stench),
  update_breeze(Breeze),
  update_glitter(Glitter),
  (arrow(0) ->  update_scream(Scream); true),
  update_confirmed_wumpus,
  update_safe,
  update_wumpus_graph.

update_wumpus_graph :-
  location([X,Y]),
  X1 is X + 1,
  X2 is X - 1,
  Y1 is Y + 1,
  Y2 is Y - 1,
  ( in_bounds([X1,Y]), \+ wumpus_arc([X,Y], [X1,Y], 1), \+ wumpus_arc([X,Y], [X1,Y], 1)	->	assert(wumpus_arc(([X,Y]), [X1,Y], 1)), assert(wumpus_arc(([X1,Y]), [X,Y], 1)), format("adding tile from [~w,~w] to [~w,~w]\n", [X,Y, X1,Y]); true ),
  ( in_bounds([X2,Y]), \+ wumpus_arc([X,Y], [X2,Y], 1), \+ wumpus_arc([X,Y], [X2,Y], 1) ->	assert(wumpus_arc(([X,Y]), [X2,Y], 1)), assert(wumpus_arc(([X2,Y]), [X,Y], 1)), format("adding tile from [~w,~w] to [~w,~w]\n", [X,Y, X2,Y]); true ),
  ( in_bounds([X,Y1]), \+ wumpus_arc([X,Y], [X,Y1], 1), \+ wumpus_arc([X,Y], [X,Y1], 1)	->	assert(wumpus_arc(([X,Y]), [X,Y1], 1)), assert(wumpus_arc(([X,Y1]), [X,Y], 1)), format("adding tile from [~w,~w] to [~w,~w]\n", [X,Y, X,Y1]); true ),
  ( in_bounds([X,Y2]), \+ wumpus_arc([X,Y], [X,Y2], 1), \+ wumpus_arc([X,Y], [X,Y2], 1)	->	assert(wumpus_arc(([X,Y]), [X,Y2], 1)), assert(wumpus_arc(([X,Y2]), [X,Y], 1)), format("adding tile from [~w,~w] to [~w,~w]\n", [X,Y, X,Y2]); true ).

safe_location([X, Y]) :-
  location([X1, Y1]),
  retractall(safe([X, Y])),
  assert(safe([X, Y])),
  assert(arc([X1, Y1], [X, Y], 1)),
  assert(arc([X, Y], [X1, Y1], 1)).

update_safe :-
  location([X, Y]),
  X1 is X + 1,
  X2 is X - 1,
  Y1 is Y + 1,
  Y2 is Y - 1,
  ( pit(no,[X1,Y]), wumpus(no,[X1,Y]), in_bounds([X1, Y]), \+ safe([X1,Y])	->	safe_location([X1,Y]), format("adding safe spot at [~w,~w]\n", [X1,Y]); true ),
  ( pit(no,[X2,Y]), wumpus(no,[X2,Y]), in_bounds([X2, Y]), \+ safe([X2,Y]) 	->	safe_location([X2,Y]), format("adding safe spot at [~w,~w]\n", [X2,Y]); true ),
  ( pit(no,[X,Y1]), wumpus(no,[X,Y1]), in_bounds([X, Y1]), \+ safe([X,Y1])	->	safe_location([X,Y1]), format("adding safe spot at [~w,~w]\n", [X,Y1]); true ),
  ( pit(no,[X,Y2]), wumpus(no,[X,Y2]), in_bounds([X, Y2]), \+ safe([X,Y2])	->	safe_location([X,Y2]), format("adding safe spot at [~w,~w]\n", [X,Y2]); true ).

update_scream(yes) :-
  retractall(wumpus(_,_)),
  assert(wumpus(no, [1,1])),
  forall(
    (world_size(S), between(1, S, X), between(1, S, Y)),
    assert(wumpus(no, [X, Y]))
  ),
  retractall(wumpus_dead(_)),
  assert(wumpus_dead(1)),
  format("Wumpus is dead, all cells marked safe from wumpuses.").

update_scream(no) :-
  critical_zone([C1, C2]),
  retractall(wumpus(_,[C1, C2])),
  assert(wumpus(no, [C1, C2])).

update_confirmed_wumpus :-
  findall([X, Y], wumpus(yes, [X, Y]), Wumpus_locations_left),
  length(Wumpus_locations_left, Count),
  ( Count == 1 ->
      Wumpus_locations_left = [[C1, C2]], 
      assert(confirmed_wumpus([C1, C2])),
      format("Confirmed wumpus updated: [~w,~w]\n", [C1, C2]),
      set_all_tiles([C1, C2]); true
  ).

set_all_tiles(ConfirmedWumpus) :-
  forall(
      (world_size(S), between(1, S, X), between(1, S, Y)),
      (ConfirmedWumpus \= [X,Y] -> assert(wumpus(no, [X, Y])); true)
  ),
  retractall(wumpus(_, ConfirmedWumpus)),
  assert(wumpus(yes, ConfirmedWumpus)).

update_stench(yes) :-
  location([X, Y]),
  X1 is X + 1,
  X2 is X - 1,
  Y1 is Y + 1,
  Y2 is Y - 1, 
  ( \+ visited([X, Y1]), \+ wumpus(no, [X, Y1]), in_bounds([X, Y1]) ->  retractall(wumpus(_, [X, Y1])), assert(wumpus(yes, [X, Y1])), format("Asserted wumpus(yes, [~w, ~w])\n", [X, Y1]); true  ),
  ( \+ visited([X, Y2]), \+ wumpus(no, [X, Y2]), in_bounds([X, Y2]) ->  retractall(wumpus(_, [X, Y2])), assert(wumpus(yes, [X, Y2])), format("Asserted wumpus(yes, [~w, ~w])\n", [X, Y2]); true  ),
  ( \+ visited([X1, Y]), \+ wumpus(no, [X1, Y]), in_bounds([X1, Y]) ->  retractall(wumpus(_, [X1, Y])), assert(wumpus(yes, [X1, Y])), format("Asserted wumpus(yes, [~w, ~w])\n", [X1, Y]); true  ),
  ( \+ visited([X2, Y]), \+ wumpus(no, [X2, Y]), in_bounds([X2, Y]) ->  retractall(wumpus(_, [X2, Y])), assert(wumpus(yes, [X2, Y])), format("Asserted wumpus(yes, [~w, ~w])\n", [X2, Y]); true  ).

update_stench(no) :-
  location([X, Y]),
  X1 is X + 1,
  X2 is X - 1,
  Y1 is Y + 1,
  Y2 is Y - 1,
  retractall(wumpus(_, [X, Y1])),
  retractall(wumpus(_, [X, Y2])),
  retractall(wumpus(_, [X1, Y])),
  retractall(wumpus(_, [X2, Y])),
  format("Asserted wumpus(no, [~w, ~w])\n", [X, Y1]),
  format("Asserted wumpus(no, [~w, ~w])\n", [X, Y2]),
  format("Asserted wumpus(no, [~w, ~w])\n", [X1, Y]),
  format("Asserted wumpus(no, [~w, ~w])\n", [X2, Y]),
  assert(wumpus(no, [X, Y1])),
  assert(wumpus(no, [X, Y2])),
  assert(wumpus(no, [X1, Y])),
  assert(wumpus(no, [X2, Y])).

update_breeze(yes) :-
  location([X, Y]),
  X1 is X + 1,
  X2 is X - 1,
  Y1 is Y + 1,
  Y2 is Y - 1,
  retractall(pit(_, [X, Y1])),
  retractall(pit(_, [X, Y2])),
  retractall(pit(_, [X1, Y])),
  retractall(pit(_, [X2, Y])),
  ( \+ visited([X, Y1]), \+ pit(no, [X, Y1]) ->  assert(pit(yes, [X, Y1])), format("Asserted pit(yes, [~w, ~w])\n", [X, Y1]); true  ),
  ( \+ visited([X, Y2]), \+ pit(no, [X, Y2]) ->  assert(pit(yes, [X, Y2])), format("Asserted pit(yes, [~w, ~w])\n", [X, Y2]); true  ),
  ( \+ visited([X1, Y]), \+ pit(no, [X1, Y]) ->  assert(pit(yes, [X1, Y])), format("Asserted pit(yes, [~w, ~w])\n", [X1, Y]); true  ),
  ( \+ visited([X2, Y]), \+ pit(no, [X2, Y]) ->  assert(pit(yes, [X2, Y])), format("Asserted pit(yes, [~w, ~w])\n", [X2, Y]); true  ).

update_breeze(no) :-
  location([X, Y]),
  X1 is X + 1,
  X2 is X - 1,
  Y1 is Y + 1,
  Y2 is Y - 1,
  retractall(pit(_, [X, Y1])),
  retractall(pit(_, [X, Y2])),
  retractall(pit(_, [X1, Y])),
  retractall(pit(_, [X2, Y])),
  format("Asserted pit(no, [~w, ~w])\n", [X, Y1]),
  format("Asserted pit(no, [~w, ~w])\n", [X, Y2]),
  format("Asserted pit(no, [~w, ~w])\n", [X1, Y]),
  format("Asserted pit(no, [~w, ~w])\n", [X2, Y]),
  assert(pit(no, [X, Y1])),
  assert(pit(no, [X, Y2])),
  assert(pit(no, [X1, Y])),
  assert(pit(no, [X2, Y])).

update_glitter(yes) :-
  location([X, Y]),
  assert(gold(yes, [X, Y])).

update_glitter(no) :-
  location([X, Y]),
  assert(gold(no, [X, Y])).

in_bounds([X, Y]) :-
  world_size(S),
  X > 0,
  X =< S,
  Y > 0,
  Y =< S.

safe_bfs(Source, Safe_Node) :-
  safe_bfs([Source], [], Safe_Node),
  format("BFS complete, next safe node found at ~w\n", [Safe_Node]).

safe_bfs([], _, none).

safe_bfs([Curr|Queue], BFS_Visited, Safe_Node) :-
  (   safe(Curr), \+ visited(Curr) -> Safe_Node = Curr; 
      findall(Next_Node, (arc(Curr, Next_Node, 1), \+ member(Next_Node, BFS_Visited)), Next_Nodes),
      append(Queue, Next_Nodes, New_Queue),
      safe_bfs(New_Queue, [Curr|BFS_Visited], Safe_Node)
  ).

wumpus_bfs(Source, Wumpus_Node) :-
  wumpus_bfs([Source], [], Wumpus_Node),
  format("Wumpus BFS complete, next wumpus node found at ~w\n", [Wumpus_Node]).

wumpus_bfs([], _, none).

wumpus_bfs([Curr|Queue], BFS_Visited, Wumpus_Node) :-
  (   wumpus(yes, Curr), \+ visited(Curr) -> Wumpus_Node = Curr; 
      findall(Next_Node, (wumpus_arc(Curr, Next_Node, 1), \+ member(Next_Node, BFS_Visited)), Next_Nodes),
      append(Queue, Next_Nodes, New_Queue),
      wumpus_bfs(New_Queue, [Curr|BFS_Visited], Wumpus_Node)
  ).

shortest_path(Source, Destination, Path) :-
  all_paths(Source, Destination, Shortest_Paths),
  Shortest_Paths = [[Path|_]|_],
  format("Shortest path found: ~w\n", [Path]).

shortest_path_wumpus(Source, Destination, Path) :-
  format("Starting Search: ~w | ~w\n", [Source, Destination]),
  w_all_paths(Source, Destination, Shortest_Paths),
  Shortest_Paths = [[Path|_]|_],
  format("Shortest wumpus path found: ~w\n", [Path]).

%return action that leads to closest safe square that has not been visited
query_knowledgebase(Action) :-
  location([X, Y]),
  findall(C, safe(C), L),
  format("safe coordinates: ~w\n", [L]),
  findall(D, visited(D), L1),
  format("visited coordinates: ~w\n", [L1]),
  safe_bfs([X, Y], Safe_Node),
  ( confirmed_wumpus([W1, W2]) -> shortest_path_wumpus([X, Y], [W1, W2], WumpusPath);
    wumpus(yes, _) -> wumpus_bfs([X, Y], Wumpus_Node), format("searching for shortest path to ~w\n", [Wumpus_Node]), shortest_path_wumpus([X, Y], Wumpus_Node, WumpusPath);
    true
  ),
  (shortest_path([X, Y], [1, 1], ExitPath);true),
  ( Safe_Node \= none -> shortest_path([X, Y], Safe_Node, Path); true),
  ( confirmed_wumpus(_), wumpus_dead(0) -> format("confirmed wumpus - attempting to kill\n"), get_best_action_execute_wumpus(WumpusPath, Action);
    Safe_Node == none, wumpus(yes, _) -> format("no other options, need to shoot to progress\n"), get_best_action_execute_wumpus(WumpusPath, Action);
    has_gold(1) ->  format("got gold, escape asap\n"), get_best_action_exit(ExitPath, Action);
    Safe_Node \= none -> format("explore safe tiles\n"), get_best_action(Path, Action);
    Safe_Node == none, \+ wumpus(yes, _) -> format("escape cave, impossible\n"), get_best_action_exit(ExitPath, Action)
  ).

is_facing([X1, Y1], [X2, Y2], Angle, IsFacing) :-
  format('Check is_facing: X1=~w, Y1=~w, X2=~w, Y2=~w, Angle=~w\n', [X1, Y1, X2, Y2, Angle]),
  (
      Angle == 0, X2 is X1 + 1, Y2 == Y1 -> format('Condition 1 met\n'), IsFacing is 1;
      Angle == 90, X2 == X1, Y2 is Y1 + 1 -> format('Condition 2 met\n'), IsFacing is 1;
      Angle == 180, X2 is X1 - 1, Y2 == Y1 -> format('Condition 3 met\n'), IsFacing is 1;
      Angle == 270, X2 == X1, Y2 is Y1 - 1 -> format('Condition 4 met\n'), IsFacing is 1;
      IsFacing = 0
  ).

get_best_action([_, NextTile | _], Action) :-
  orientation(Angle),
  location([X, Y]),
  is_facing([X, Y], NextTile, Angle, IsFacing),
  format("Orientation: ~w, Location: ~w, isFacing: ~w\n", [Angle, [X, Y], IsFacing]),
  ( gold(yes, [X, Y]) -> Action = grab;
    IsFacing is 1 -> Action = goforward, format("choose action goforward\n");
    Action = turnleft, format("choose action turnleft\n")
  ).

get_best_action_exit([_, NextTile | _], Action) :-
  orientation(Angle),
  location([X, Y]),
  is_facing([X, Y], NextTile, Angle, IsFacing),
  ( gold(yes, [X, Y]) -> Action = grab;
    [X, Y] = [1, 1] -> Action = climb;
    IsFacing == 1 -> Action = goforward;
    Action = turnleft
  ).

get_best_action_execute_wumpus([_, NextTile | _], Action) :-
  orientation(Angle),
  location([X, Y]),
  is_facing([X, Y], NextTile, Angle, IsFacing),
  ( wumpus(yes, NextTile), IsFacing == 1 -> Action = shoot;
    IsFacing == 1 -> Action = goforward;
    Action = turnleft
  ).

% Shortest Path Logic
not_member(_, []) :- !.
not_member(X, [Head|Tail]) :-
    X \= Head,
    not_member(X, Tail).

all_paths(A, B, Reversed) :-
    findall([Path, Distance], path(A, B, [], Path, Distance), Paths),
    sort(2, @=<, Paths, Sorted),
    extract_value(Sorted, Value),
    delete_if(Sorted, Value, Filtered),
    reverse_city_lists(Filtered, Reversed).

path(A, B, Visited, Path, TotalDistance) :- 
    arc(A, M, D),
    M == B,
    TotalDistance is D,
    Path = [B, A | Visited].

path(A, B, Visited, Path, TotalDistance) :-
    arc(A, M, D),
    M \= A,
    not_member(M, Visited),
    path(M, B, [A | Visited], Path, Distance),
    TotalDistance is Distance + D.

delete_if([], _, []).

delete_if([[_, Value] | Tail], Limit, Filtered) :-
    Value > Limit,
    !,
    delete_if(Tail, Limit, Filtered).

delete_if([Head | Tail], Limit, [Head | Filtered]) :-
    delete_if(Tail, Limit, Filtered).

extract_value([[_, Value] | _], Value).

reverse_city_lists([], []).
reverse_city_lists([[Cities, Distance] | Rest], [[ReversedCities, Distance] | ReversedRest]) :-
    reverse(Cities, ReversedCities),
    reverse_city_lists(Rest, ReversedRest).

reverse_all_paths(Paths, ReversedPaths) :-
    maplist(reverse_city_lists, Paths, ReversedPaths).

%Wumpus Shortest Path Logic
w_not_member(_, []) :- !.
w_not_member(X, [Head|Tail]) :-
    X \= Head,
    w_not_member(X, Tail).

w_all_paths(A, B, Reversed) :-
    findall([Path, Distance], w_path(A, B, [], Path, Distance), Paths),
    sort(2, @=<, Paths, Sorted),
    w_extract_value(Sorted, Value),
    w_delete_if(Sorted, Value, Filtered),
    w_reverse_city_lists(Filtered, Reversed).

w_path(A, B, Visited, Path, TotalDistance) :- 
    wumpus_arc(A, M, D),
    M == B,
    TotalDistance is D,
    Path = [B, A | Visited].

w_path(A, B, Visited, Path, TotalDistance) :-
    wumpus_arc(A, M, D),
    M \= A,
    w_not_member(M, Visited),
    w_path(M, B, [A | Visited], Path, Distance),
    TotalDistance is Distance + D.

w_delete_if([], _, []).

w_delete_if([[_, Value] | Tail], Limit, Filtered) :-
    Value > Limit,
    !,
    w_delete_if(Tail, Limit, Filtered).

w_delete_if([Head | Tail], Limit, [Head | Filtered]) :-
    w_delete_if(Tail, Limit, Filtered).

w_extract_value([[_, Value] | _], Value).

w_reverse_city_lists([], []).
w_reverse_city_lists([[Cities, Distance] | Rest], [[ReversedCities, Distance] | ReversedRest]) :-
    reverse(Cities, ReversedCities),
    w_reverse_city_lists(Rest, ReversedRest).

w_reverse_all_paths(Paths, ReversedPaths) :-
    maplist(reverse_city_lists, Paths, ReversedPaths).




