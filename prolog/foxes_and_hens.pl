config([3,3,1],[0,0,0]).
avoid_loop(Next,Explored) :- not(member(Next,Explored)).

/*
printVisited([]) :- nl,nl,nl.
printVisited([[F,H]|T]) :- write(F),write('-->'),write(H),nl,printVisited(T).
*/

% Set up the list of visited nodes
solve([Start|Moves]) :- 
	config(Start,Goal),
	search(Start,Goal,[Start],Moves).
	
% Make valid moves and add to path
search(Goal,Goal,_,[]).
search(Start,Goal,Explored,MovesList) :-
	move(Start,Next),
	avoid_loop(Next,Explored),
	valid_transfer(Start,Next),
	search(Next,Goal,[Next|Explored],CompleteSolution),
	MovesList = [Next|CompleteSolution].
	
% Check if east|west are different
valid_transfer([_,_,S1],[_,_,S2]) :- not(S1==S2).
	
% Assure that the move is to a valid state
safe_state(F1,H1) :- 
	(F1 =< H1 ; H1 = 0),
	 F2 is 3-F1, H2 is 3-H1,
	(F2 =< H2 ; H2 = 0), !. 

% Valid moves that we can make
move([F1,H1,1],[F2,H1,0]) :- F1 > 0, F2 is F1-1, safe_state(F2,H1).   
move([F1,H1,1],[F2,H1,0]) :- F1 > 1, F2 is F1-2, safe_state(F2,H1).  
move([F1,H1,1],[F1,H2,0]) :- H1 > 0, H2 is H1-1, safe_state(F1,H2). 
move([F1,H1,1],[F1,H2,0]) :- H1 > 1, H2 is H1-2, safe_state(F1,H2). 
move([F1,H1,0],[F2,H1,1]) :- F1 < 3, F2 is F1+1, safe_state(F2,H1). 
move([F1,H1,0],[F2,H1,1]) :- F1 < 2, F2 is F1+2, safe_state(F2,H1). 
move([F1,H1,0],[F1,H2,1]) :- H1 < 3, H2 is H1+1, safe_state(F1,H2). 
move([F1,H1,0],[F1,H2,1]) :- H1 < 2, H2 is H1+2, safe_state(F1,H2).

move([F1,H1,1],[F2,H2,0]) :- F1 > 0, H1 > 0, F2 is F1-1, H2 is H1-1, safe_state(F2,H2).
move([F1,H1,0],[F2,H2,1]) :- F1 < 3, H1 < 3, F2 is F1+1, H2 is H1+1, safe_state(F2,H2).