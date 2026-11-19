/* INTELLIGENT TIMETABLE GENERATOR - Turbo Prolog 2.0
   Constraint satisfaction, backtracking and knowledge representation */

domains
  entry = e(symbol, symbol, symbol, symbol)   /* subject, teacher, room, slot */
  elist = entry*
  slist = symbol*

database
  subject(symbol, symbol, integer, symbol)    /* name, teacher, lectures, type */
  teacher_unavailable(symbol, symbol)         /* teacher, slot */
  room_blocked(symbol, symbol)                /* room, slot */

predicates
  room(symbol, symbol)
  slot(symbol, string)
  next(symbol, symbol)
  consecutive(symbol, symbol)
  room_ok(symbol, symbol)
  append(slist, slist, slist)
  len(slist, integer)
  repeat_n(symbol, integer, slist)
  expand(slist, slist)
  lectures(slist)
  schedule(slist, elist, elist)
  slot_used(symbol, elist)
  teacher_busy(symbol, symbol, elist)
  room_busy(symbol, symbol, elist)
  back_to_back(symbol, symbol, elist)
  show_entry(symbol, elist)
  show_tt(elist)
  generate
  why_failed(slist)
  change(symbol, integer)
  show_facts
  header
  menu
  choice(char)

clauses
  /* ---------- FACTS: subjects (name, teacher, lectures, type) ---------- */
  subject(ai,     teacher_a, 2, theory).
  subject(python, teacher_b, 2, practical).
  subject(dbms,   teacher_c, 1, theory).

  /* ---------- FACTS: availability ---------- */
  room_blocked(r102, wed_9am).

  /* ---------- FACTS: rooms and slots ---------- */
  room(r101, classroom).
  room(r102, lab).

  slot(mon_9am,  "Monday 9 AM").
  slot(mon_10am, "Monday 10 AM").
  slot(tue_9am,  "Tuesday 9 AM").
  slot(tue_10am, "Tuesday 10 AM").
  slot(wed_9am,  "Wednesday 9 AM").

  next(mon_9am, mon_10am).
  next(tue_9am, tue_10am).

  consecutive(A, B) :- next(A, B).
  consecutive(A, B) :- next(B, A).

  /* practical -> lab, theory -> classroom */
  room_ok(practical, lab).
  room_ok(theory, classroom).

  /* ---------- LIST HELPERS ---------- */
  append([], L, L).
  append([H|T], L, [H|R]) :- append(T, L, R).

  len([], 0).
  len([_|T], N) :- len(T, N1), N = N1 + 1.

  repeat_n(_, 0, []) :- !.
  repeat_n(S, N, [S|T]) :- N1 = N - 1, repeat_n(S, N1, T).

  expand([], []).
  expand([S|T], L) :-
      subject(S, _, N, _),
      repeat_n(S, N, R),
      expand(T, L2),
      append(R, L2, L).

  /* PRIORITY: practical subjects are placed first */
  lectures(L) :-
      findall(S, subject(S, _, _, practical), P),
      findall(S, subject(S, _, _, theory), T),
      append(P, T, All),
      expand(All, L).

  /* ---------- CONSTRAINT SATISFACTION WITH BACKTRACKING ---------- */
  schedule([], Acc, Acc).
  schedule([S|Rest], Acc, Result) :-
      subject(S, T, _, Type),
      slot(Sl, _),
      room(R, RType),
      room_ok(Type, RType),
      not(teacher_unavailable(T, Sl)),
      not(room_blocked(R, Sl)),
      not(slot_used(Sl, Acc)),
      not(teacher_busy(T, Sl, Acc)),
      not(room_busy(R, Sl, Acc)),
      not(back_to_back(S, Sl, Acc)),
      schedule(Rest, [e(S, T, R, Sl)|Acc], Result).

  /* the class attends one lecture per slot */
  slot_used(Sl, [e(_, _, _, Sl)|_]) :- !.
  slot_used(Sl, [_|T]) :- slot_used(Sl, T).

  teacher_busy(T, Sl, [e(_, T, _, Sl)|_]) :- !.
  teacher_busy(T, Sl, [_|Tail]) :- teacher_busy(T, Sl, Tail).

  room_busy(R, Sl, [e(_, _, R, Sl)|_]) :- !.
  room_busy(R, Sl, [_|Tail]) :- room_busy(R, Sl, Tail).

  back_to_back(S, Sl, [e(S, _, _, Sl2)|_]) :- consecutive(Sl, Sl2), !.
  back_to_back(S, Sl, [_|Tail]) :- back_to_back(S, Sl, Tail).

  /* ---------- OUTPUT ---------- */
  show_entry(Sl, [e(S, T, R, Sl)|_]) :- !,
      write(S, " | ", T, " | ", R), nl.
  show_entry(Sl, [_|Tail]) :- !, show_entry(Sl, Tail).
  show_entry(_, []) :- write("free"), nl.

  show_tt(TT) :-
      slot(Sl, Name),
      write(Name, " : "),
      show_entry(Sl, TT),
      fail.
  show_tt(_).

  generate :-
      lectures(L),
      schedule(L, [], TT), !,
      write("GENERATED TIMETABLE"), nl, nl,
      show_tt(TT), nl,
      write("Status: Timetable generated without teacher or room clashes."), nl.
  generate :-
      lectures(L),
      write("Status: NO valid timetable could be created."), nl,
      why_failed(L).

  /* ---------- REASONING: why it failed ---------- */
  why_failed(L) :-
      len(L, N),
      findall(S, slot(S, _), SL), len(SL, M),
      N > M, !,
      write("Reason: ", N, " lectures needed but only ", M, " slots exist."), nl.
  why_failed(_) :-
      write("Reason: teacher availability, room type or the"), nl,
      write("        no-consecutive rule cannot all be satisfied."), nl.

  /* ---------- CHANGE NUMBER OF LECTURES ---------- */
  change(S, N) :-
      retract(subject(S, T, _, Ty)), !,
      assertz(subject(S, T, N, Ty)),
      write("Saved: ", S, " now has ", N, " lecture(s)"), nl.
  change(_, _) :- write("Subject not found."), nl.

  show_facts :-
      write("SUBJECTS:"), nl,
      subject(S, T, N, Ty),
      write("  ", S, " - ", T, " - ", N, " lecture(s) - ", Ty), nl,
      fail.
  show_facts :-
      nl, write("NOT AVAILABLE:"), nl,
      teacher_unavailable(T, Sl),
      write("  ", T, " at ", Sl), nl,
      fail.
  show_facts :-
      room_blocked(R, Sl),
      write("  room ", R, " at ", Sl), nl,
      fail.
  show_facts.

  header :-
      nl, write("===== INTELLIGENT TIMETABLE GENERATOR ====="), nl, nl.

  /* ---------- MENU ---------- */
  menu :-
      nl, write("1. Generate timetable"), nl,
      write("2. Mark a teacher unavailable"), nl,
      write("3. Change lectures of a subject"), nl,
      write("4. Show facts"), nl,
      write("0. Exit"), nl,
      write("Choice: "), readchar(C), write(C), nl,
      choice(C).

  choice('1') :- !, header, generate, menu.
  choice('2') :- !,
      write("Teacher (teacher_a/teacher_b/teacher_c): "), readln(T),
      write("Slot (mon_9am/mon_10am/tue_9am/tue_10am/wed_9am): "), readln(Sl),
      assertz(teacher_unavailable(T, Sl)),
      write("Saved: ", T, " unavailable at ", Sl), nl, menu.
  choice('3') :- !,
      write("Subject (ai/python/dbms): "), readln(S),
      write("New number of lectures: "), readint(N),
      change(S, N), menu.
  choice('4') :- !, header, show_facts, menu.
  choice('0') :- !.
  choice(_) :- menu.

goal
  header,
  menu.
