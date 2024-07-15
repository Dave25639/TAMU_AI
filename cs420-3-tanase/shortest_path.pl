% Sun 24 Mar 2024 12:07:00 PM CDT
% Shortest Path Algorithm
% Usage: all_paths({start}, {end}, Paths).
% By: David Tanase
% 
% This program assumes that to navigate from a to a, 
% an arc must be explicitly defined.
%

:- dynamic(arc/3).

% arc(cstat, austin, 0).
% arc(austin, sana, 5).
% arc(austin, austin, 100).
% arc(cstat, sana, 5).
% arc(sana, cstat, 100000).
arc([1,1], [2,1], 1).
arc([2,1], [1,1], 1).
arc([1,1], [1,2], 1).
arc([1,2], [1,1], 1).
arc([2,1], [3,1], 1).
arc([3,1], [2,1], 1).
arc([2,1], [2,2], 1).
arc([2,2], [2,1], 1).
arc([1,2], [2,2], 1).
arc([2,2], [1,2], 1).
arc([1,2], [1,3], 1).
arc([1,3], [1,2], 1).
arc([2,2], [3,2], 1).
arc([3,2], [2,2], 1).
arc([2,2], [2,3], 1).
arc([2,3], [2,2], 1).

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

% Recursive case: If the head of the list meets the condition, skip it.
delete_if([[_, Value] | Tail], Limit, Filtered) :-
    Value > Limit,
    !,
    delete_if(Tail, Limit, Filtered).

% Recursive case: If the head of the list does not meet the condition, keep it.
delete_if([Head | Tail], Limit, [Head | Filtered]) :-
    delete_if(Tail, Limit, Filtered).

extract_value([[_, Value] | _], Value).

reverse_city_lists([], []).
reverse_city_lists([[Cities, Distance] | Rest], [[ReversedCities, Distance] | ReversedRest]) :-
    reverse(Cities, ReversedCities),
    reverse_city_lists(Rest, ReversedRest).

reverse_all_paths(Paths, ReversedPaths) :-
    maplist(reverse_city_lists, Paths, ReversedPaths).