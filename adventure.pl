/* Escaping La Catedral! by Anthony Georgiades. */

:- dynamic i_am_at/1, at/2, holding/1, i_am_killed/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(holding(_)), retractall(i_am_killed(_)).

/*locations*/
path(lounge, e, frontdoor).
path(frontdoor, w, lounge).

path(safe_entrance, s, lounge).
path(lounge, n, safe_entrance).

path(lounge, s, hallway).
path(hallway, n, lounge).

path(safe_entrance, w, safe).
path(safe, e, safe_entrance).

path(safe, w, tunnel_entrance).
path(tunnel_entrance, e, safe).

path(tunnel_entrance, w, tunnel).
path(tunnel, e, tunnel_entrance).

path(hallway, w, backdoor).
path(backdoor, e, hallway).

path(hallway, w, backdoor).
path(backdoor, e, hallway).

/*initial states*/
gun(loaded).
health(good).
mortal(true).
bomb(notinitiated).

/*set initial location*/
i_am_at(lounge).

/*Predicate with functor being takeable and arity being 1*/
/* These rules describe how to pick up an object. */
takeable(gun).
takeable(bomb).
takeable(money).
takeable(machete).
takeable(key).
takeable(combination).

nontakeable(dresser).

at(gun, lounge).
at(bomb, safe).
at(money, safe).
at(machete, lounge).
at(key, safe).
at(combination, backdoor).
at(dresser, hallway).


take(combination) :-
        holding(combination),
        write('You now have the combination to open the safe! '),
        !, nl.


take(X) :-
        holding(X),
        write('You''re already holding it!'),
        !, nl.

take(bomb) :-
        write('Be Careful!'),
        !, nl.

take(X) :-
        \+takeable(X),
        write('Can\'t take that'),
        !,fail.

take(X) :-
        i_am_at(Place),
        takeable(X),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)),
        write('You are now holding '), write(X), write('!'),
        !, nl.


take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */


drop(bomb) :-
        i_am_at(frontdoor),
        holding(bomb),
        retract(holding(bomb)),
        assert(at(bomb, frontdoor)),
        write('You have just activated the bomb and have initiated personal destruction of La Catedral'),
        finish.

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.

/* These rules define the direction letters as calls to go */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(w) :-
        i_am_at(safe_entrance),
        path(safe_entrance, w, safe),
        \+holding(combination),
        write('You need the combination to open the safe!'),
        !, look.

go(w) :-
        i_am_at(safe_entrance),
        path(safe_entrance, w, safe),
        retract(i_am_at(safe_entrance)),
        assert(i_am_at(safe)),
        write('You have opened the safe!  '),
        !, look.

go(w) :-
        i_am_at(safe),
        path(safe, w, tunnel_entrance),
        \+holding(key),
        write('You need the key to enter the tunnel '),
        !, look.

go(w) :-
        i_am_at(safe),
        path(safe, w, tunnel_entrance),
        retract(i_am_at(safe)),
        assert(i_am_at(tunnel_entrance)),
        holding(key),
        write('You can now open entrance and enter the the tunnel to escape!  '),
        !, look.

go(w) :-
        i_am_at(tunnel_entrance),
        path(tunnel_entrance, w, tunnel),
        retract(i_am_at(tunnel_entrance)),
        assert(i_am_at(tunnel)),
        holding(key),
        write('Yay, you have made it into the tunnel!'),
        finish.

/* go(w) :-
        i_am_at(hallway),
        path(hallway, w, backdoor),
        retract(i_am_at(hallway)),
        assert(i_am_at(backdoor)),
        counter(w),
        !, look. */


go(Direction) :-
        i_am_at(X),
        path(X, Direction, Y),
        retract(i_am_at(X)),
        assert(i_am_at(Y)),
        !, look.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects in your vicinity. */

notice_objects_at(backdoor) :-
        at(combination, backdoor),
        write('Is there anything here?'), nl,
        !, fail.

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

counter(Count) :-
    pred(..., Count, Count).
    pred(..., Counter, Count) :-
        ...,
        Counter1 = Counter + 1,
        pred(..., Counter1, Count),
        assert(Count=15),
        write('You have been shot too many times and are dead!'),
        finish.


die :-
        i_am_at(frontdoor),
        holding(bomb),
        drop(bomb),
        retract(holding(bomb)),
        assert(at(bomb, frontdoor)),
        write('You have just activated the bomb and have initiated personal destruction of La Catedral'),
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('i.                 -- to see what you are currently holding.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.

i :- 
        holding(_),
        write('You are holding the following:'), nl,!,
        holding(X),
        write(X), nl,
        fail.   

/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        describe(initial),
        look.


/* These rules describe the various rooms.  Depending on circumstances, a room may have more than one description. */

describe(initial) :- write('You are Pablo Escobar and you are currently in the lounge of La Catedral. You are under attack by the DEA! Luckily, you have built an escape tunnel, which you can only open with the key. Unfortunately, the key is locked in the safe which requires a special combo to open. The combination is hidden somewhere in La Catedral!'), nl.
describe(lounge) :- write('You are at the lounge and getting attacked. Go to the safe, get the key, go to tunnel and escape'), nl.
describe(frontdoor) :- write('You are at the front door and under heavy attack! You do not have eough ammo to fend everyone else! Turn around or blow everyone up with the bomb!'), nl.
describe(backdoor) :- write('You cannot leave through the backdoor becasue they have surrounded the buildling! Go back and find the combination, use it to open the safe, get the key in the safe and leave through the tunnel!'), nl.
describe(safe_entrance) :- write('You are at the entrance of the safe! To open the safe, you need the combination hidden somewhere in La Catedral! Once you open the safe, you can retrieve the key to enter the tunnel or the bomb to self destruct'), nl.
describe(safe) :- write('Now you can take the key and proceed to the tunnel entrance, or take the bomb. Choose your own fate!'), nl.
describe(tunnel_entrance) :- write('With the key in hand, unlock the lock to go into the tunnel and escape. You must have key! If not, go back to safe and get it'), nl.
describe(hallway) :- write('You are in the hallway! You can either go to the backdoor or turnaround and go back to the lounge'), nl.


