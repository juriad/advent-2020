:- module prg.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module string, list, int, maybe, set.

:- type range --->
	range(
		min :: int,
		max :: int
	).

:- type label --->
	label(
		name :: string,
		ranges :: list(range)
	).

:- type ticket --->
	ticket(
		numbers :: list(number)
	).

:- type number --->
	number(
		value :: int,
		matching :: list(label)
	).

:- type input --->
	input(
		labels :: list(label),
		your :: ticket,
		nearby :: list(ticket)
	).
	
:- type match --->
	match(
		index :: int,
		label :: string
	).

main(!IO) :-
	load_file(MInput, !IO),
	(
		MInput = maybe.yes(Input),
		solve(Input, Task1, Task2)
	->
		io.format("%d\n%d\n", [i(Task1), i(Task2)], !IO)
	;
		true
	).
	

:- pred solve(input::in, int::out, int::out) is semidet.
solve(Input, Task1, Task2) :-
	filter(is_valid_ticket, Input^nearby, ValidTickets, InvalidTickets),
	map(invalid_numbers, InvalidTickets, InvalidNums),
	Task1 = foldl(plus, condense(InvalidNums), 0),
	
	unify_valid_tickets(ValidTickets, Matches),
	filter_map(departure_index, Matches, DepartureIndices),
	map(det_index0(Input^your^numbers), DepartureIndices, YourNumbers),
	map(number_value, YourNumbers, YourValues),
	Task2 = foldl(times, YourValues, 1).

:- pred is_valid_ticket(ticket::in) is semidet.
is_valid_ticket(Ticket) :-
	all_true(is_valid_number, Ticket^numbers).

:- pred is_valid_number(number::in) is semidet.
is_valid_number(Number) :-
	Number^matching = [_ | _].

:- pred invalid_numbers(ticket::in, list(int)::out) is det.
invalid_numbers(Ticket, Nums) :-
	negated_filter(is_valid_number, Ticket^numbers, Numbers),
	map(number_value, Numbers, Nums).

:- pred number_value(number::in, int::out) is det.
number_value(Number, Value) :-
	Value = Number^value.
	
	
:- pred departure_index(match::in, int::out) is semidet.
departure_index(Match, Index) :-
	sub_string_search(Match^label, "departure", 0),
	Index = Match^index.

	
	
	
:- pred unify_valid_tickets(list(ticket)::in, list(match)::out) is semidet.
unify_valid_tickets(ValidTickets, Matches) :-
	map(ticket_numbers, ValidTickets, NumericTickets),
	unify_numbers(NumericTickets, Matches).
	
:- pred ticket_numbers(ticket::in, list(number)::out) is det.
ticket_numbers(Ticket, Numbers) :-
	Numbers = Ticket^numbers.


:- pred unify_numbers(list(list(number))::in, list(match)::out) is semidet.
unify_numbers(NumericTickets, Matches) :-
	columnwise(NumericTickets, Mat),
	map(column_to_set, Mat, Possibilities),
	match_labels(Possibilities, Matches).
	
:- pred match_labels(list(set(string))::in, list(match)::out) is semidet.
match_labels(Possibilities, Matches) :-
	find_index_of_match(is_singleton1, Possibilities, 0, Index),
	det_index0(Possibilities, Index, Singleton),
	is_singleton(Singleton, Label),
	Matches = [match(Index, Label) | Ms],
	
	map(set.delete(Label), Possibilities, Smaller),
	
	(
		all_true(set.is_empty, Smaller)
	->
		Ms = []
	;
		match_labels(Smaller, Ms)
	).
	
:- pred is_singleton1(set(T)::in) is semidet.
is_singleton1(Set) :-
	is_singleton(Set, _).
	
	

:- pred column_to_set(list(number)::in, set(string)::out) is det.
column_to_set(Column, Set) :-
	map(number_to_set, Column, Sets),
	Set = intersect_list(Sets).

:- pred number_to_set(number::in, set(string)::out) is det.
number_to_set(Number, Set) :-
	map(label_to_name, Number^matching, List),
	Set = list_to_set(List).

:- pred label_to_name(label::in, string::out) is det.
label_to_name(Label, Name) :-
	Name = Label^name.
	
	

:- pred columnwise(list(list(T))::in, list(list(T))::out) is det.
columnwise(Mat, TMat) :-
	columnwise(Mat, [], [], TMat).

:- pred columnwise(list(list(T))::in, list(list(T))::in, list(T)::in, list(list(T))::out) is det.
columnwise([], Mat, Col, [Col | Cols]) :-
	columnwise(Mat, [], [], Cols).
columnwise([[] | _], _, _, []).
columnwise([[E | Es] | Rest], Mat, Cols, Res) :-
	columnwise(Rest, [Es | Mat], [E | Cols], Res).

	
	
	

:- pred parse_label(string::in, label::out) is semidet.
parse_label(In, Out) :-
	[Head, Tail] = split_at_string(": ", In),
	StringRanges = split_at_string(" or ", Tail),
	filter_map(parse_range, StringRanges, Ranges),
	Out = label(Head, Ranges).
	
:- pred parse_range(string::in, range::out) is semidet.
parse_range(In, Out) :- 
	[StringMin, StringMax] = split_at_string("-", strip(In)),
	to_int(StringMin, Min),
	to_int(StringMax, Max),
	Out = range(Min, Max).
	
:- pred parse_ticket(list(label)::in, string::in, ticket::out) is det.
parse_ticket(Labels, In, Out) :-
	StringNums = split_at_string(",", strip(In)),
	filter_map(to_int, StringNums, Nums),
	map(parse_number(Labels), Nums, Numbers),
	Out = ticket(Numbers).

:- pred parse_number(list(label)::in, int::in, number::out) is det.
parse_number(Labels, In, Out) :-
	filter(matches_label(In), Labels, FilteredLables),
	Out = number(In, FilteredLables).
	
:- pred matches_label(int::in, label::in) is semidet.
matches_label(In, Label) :-
	any_true(in_range(In), Label^ranges).
	
:- pred in_range(int::in, range::in) is semidet.
in_range(In, Range) :-
	In >= Range^min,
	In =< Range^max.

:- pred load_file(maybe(input)::out, io::di, io::uo) is det.
load_file(Input, !IO) :-
	io.command_line_arguments(Args, !IO),
	(
		Args = [Arg | _]
	->
		io.open_input(Arg, OpenResult, !IO),
		(
			OpenResult = ok(File)
		->
			read_file(File, Input, !IO)
		;
			Input = maybe.no
		)
	;
		Input = maybe.no
	).

:- pred read_file(io.text_input_stream::in, maybe(input)::out, io::di, io::uo) is det.
read_file(File, Input, !IO) :-
	read_file_line_by_line(File, StringLabels, !IO),
	read_file_line_by_line(File, Your, !IO),
	read_file_line_by_line(File, Nearby, !IO),
	(
		filter_map(parse_label, StringLabels, Labels),
		Your = [_, Line],
		parse_ticket(Labels, Line, Ticket),
		Nearby = [_ | Lines],
		map(parse_ticket(Labels), Lines, Tickets)
	->
		Input = maybe.yes(input(Labels, Ticket, Tickets))
	;
		Input = maybe.no
	).

:- pred read_file_line_by_line(io.text_input_stream::in, list(string)::out, io::di, io::uo) is det.
read_file_line_by_line(File, Lines, !IO) :-
	io.read_line_as_string(File, ReadLineResult, !IO),
	(
		ReadLineResult = ok(Line),
		(
			Line = "\n"
		->
			Lines = []
		;
			Lines = [Line | Rest],
			read_file_line_by_line(File, Rest, !IO)
		)
	;
		ReadLineResult = eof,
		Lines = []
	;
		ReadLineResult = error(_),
		io.set_exit_status(1, !IO),
		Lines = []
	).
