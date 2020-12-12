% Grammar 
% =======
% Nonterminals expr, term, term_tail and factor_tail are encoded as
% non(e,_), non(t,_), non(tt,_) and non(ft,_), respectively. 
% Special nonterminal start is encoded as non(s,_).
% Terminals num, -, and * are encoded as 
% term(num,_), term(minus,_) and term(times,_). 
% Special terminal term(eps,_) denotes the epsilon symbol.
% 
% Productions are represented as prod(N,[H|T]) where N is the unique
% index of the production, H is the left-hand-side, and T is the 
% right-hand-side. 

prod(0,[non(s,_),non(e,_)]).
prod(1,[non(e,_),non(t,_),non(tt,_)]). 
prod(2,[non(tt,_),term(minus,_),non(t,_),non(tt,_)]).
prod(3,[non(tt,_),term(eps,_)]).
prod(4,[non(t,_),term(num,_),non(ft,_)]).
prod(5,[non(ft,_),term(times,_),term(num,_),non(ft,_)]).
prod(6,[non(ft,_),term(eps,_)]).


% LL(1) parsing table
% ===================
% Complete the LL(1) parsing table for the above grammar.
% E.g., predict(non(s,_),term(num,_),0) stands for "on start and num, 
% predict production 0. start -> expr".

predict(non(s,_),term(num,_)		,0).
predict(non(e,_),term(num,_)		,1).
predict(non(tt,_),term(minus,_)		,2).
predict(non(tt,_),term(eps,_)		,3).
predict(non(tt,_),term(end,_)		,3).
predict(non(t,_),term(num,_)		,4).
predict(non(ft,_),term(times,_)		,5).
predict(non(ft,_),term(eps,_)		,6).
predict(non(ft,_),term(end,_)		,6).


% Sample inputs
% =============
% input0([3,-,5]).
% input1([3,-,5,*,7,-,18]).


% Transform
% ========
% Transform translates a token stream into the generic representation, 
% including the special end-of-input-marker. E.g., [3,-,5] translates 
% into [term(num,3),term(minus,_),term(num,5),term(end,_)].

% Write transform(L,R): it takes input list L and transforms it into a
% list where terminals are represented with term(...). The transformed 
% list will be computed in unbound variable R.
% E.g., transform([3,-,5],R).
% R = [term(num,3),term(minus,_),term(num,5),term(end,_)]

term(minus,_).
term(times,_).
term(end,_).

transform(Input,R) :- 
	build(Input,_,R), !.
build([],R,Result) :- 
	reverse(R,Rtemp),append(Rtemp,[term(end,_)],Result).
build([H|T],R,End) :-
	(H = '-',build(T,[term(minus,_)|R],End));
	(H = '*',build(T,[term(times,_)|R],End));
	(number(H),build(T,[term(num,H)|R],End)),
	!.

% parseLL
% =======
% Write parseLL(R,ProdSeq): it takes a transformed list R and produces 
% the production sequence the predictive parser applies.
% E.g., transform([3,-,5],R),parseLL(R,ProdSeq).
% ProdSeq = [0, 1, 4, 6, 2, 4, 6, 3].

parseAndSolve(R,ProdSeq,V) :- 
	parseLL(R,[0],[non(e,_)],_,term(eps,_),V,ProdSeq).

parseLL([term(end,_)],X,[],EvalList,_,VSolution,SolutionProdSeq) :- 
	reverse(EvalList,[V|T]),
	reverse(X,SolutionProdSeq), !,
	evaluate(T,V,VSolution).
	
parseLL([Input|T],ProdSeq,[Next|Rest],EvalList,LastSign,V,P) :- (
		predict(Next,Input,N),	
		prod(N,[Next|RHS]),
		omit(RHS),
		parseLL([Input|T],[N|ProdSeq],Rest,EvalList,LastSign,V,P), !
	) ; ( 
		predict(Next,Input,N),			% Take the next nonterminal and resolve it
		prod(N,[Next|RHS]),  
		append(RHS,Rest,X),
		parseLL([Input|T],[N|ProdSeq],X,EvalList,LastSign,	V,P)
	) ; ( 
		can_consume(Input,Next),		% Consume an input token
		calculate(Input,EvalList,LastSign,EvalNew,SignNew),
		parseLL(T,ProdSeq,Rest,EvalNew,SignNew,V,P)
	) ; ( 
		predict(Next,term(eps,_),N),	% Resolve an epsilon
		parseLL([Input|T],[N|ProdSeq],Rest,EvalList,LastSign,V,P)
	).

evaluate([],V,Vresult) :- Vresult is V.
evaluate([H|T],V,Vresult) :- NewV is V-H,evaluate(T,NewV,Vresult).
omit(L) :- member(term(eps,_),L).
can_consume(term(num,_),term(num,_)).
can_consume(term(minus,_),term(minus,_)).
can_consume(term(times,_),term(times,_)).
calculate(term(times,_),L,_,L,X) :- X = term(times,_).
calculate(term(minus,_),L,_,L,X) :- X = term(minus,_).
calculate(term(num,N),[H1|T1],term(times,_),[H2|T1],_) :- H2 is N*H1.
calculate(term(num,N),T,term(eps,_),[N|T],_).
calculate(term(num,N),T,term(minus,_),[N|T],_).


% parseAndSolve
% =============
% Write parseAndSolve, which augments parseLL with computation. 
% E.g., transform([3,-,5],R),parseAndSolve(R,ProdSeq,V).
% ProdSeq = [0, 1, 4, 6, 2, 4, 6, 3],
% V = -2.