/*  File:    swipl-win.lp
    Author:  Carlo,,,
    Created: Jun 22 2013
    Purpose: Big Deal ! Running swipl-win by pqConsole !
*/

:- module('swipl-win', [setup_gui/0]).

:- use_module(library(www_browser)).
:- use_module(library(threadutil)).

%%	console_menu(Entries)
%
%	declare the menu structure similar to swipl-win.exe
%
console_menu([file-    [consult + query_file,
			edit + query_file,
			new + query_file,
			-,
                        reload * (user:make),
			-,
			navigator + query_uri,
			-,
			exit],
	      edit -   [copy,
			paste],
	      settings-[font,
			-,
			user_init_file,
			gui_preferences],
	      run-     [interrupt,
			new_thread],
	      debug-   [edit_spy_points,
                        edit_exceptions,
                        monitor_threads,
                        debug_messages,
			cross_referencer,
			-,
			graphical_debugger],
	      help-    [about,
                        console_help,
			browse_pldoc,
			-,
			swi_prolog_website,
			manual,
			faq,
			quick_start,
			mailing_list,
			download,
			extension_packs,
			-,
			xpce_gui_manual,
			-,
			submit_bug_report]
	     ]).

%%	setup_gui
%
%	instance menus in console
%
setup_gui :-
	console_menu(Menu),
	setup_menu(Menu, []).

setup_menu([], _Accel).
setup_menu([Key-Submenu|Rest], Accel) :-
	sub_atom(Key, Pos, 1, _, Ampersand),
	\+ memberchk(Ampersand, Accel),
	!, make_label(Key, Pos, Label),
	win_insert_menu(Label, -),
	setup_submenu(Submenu, Label, []),
	setup_menu(Rest, [Ampersand|Accel]).

make_label(WithUnderscore, Pos, Label) :-
	atomic_list_concat(Parts, '_', WithUnderscore),
	maplist(make_first_upcase, Parts, UpcaseParts),
	atomic_list_concat(UpcaseParts, ' ', Upcase),
	sub_atom(Upcase, 0, Pos, _, Left),
	sub_atom(Upcase, Pos, _, 0, Right),
	format(atom(Label), '~s&~s', [Left, Right]).

make_first_upcase(Low, Up) :-
	atom_codes(Low, [LoFirst|Cs]),
	code_type(LoFirst, to_lower(UpFirst)),
	atom_codes(Up, [UpFirst|Cs]).

setup_submenu([], _Menu, _Accel).
setup_submenu([-|Commands], Menu, Accel) :-
	win_insert_menu_item(Menu, -, -, -),
	setup_submenu(Commands, Menu, Accel).
setup_submenu([Command|Commands], Menu, Accel) :-
	(   Command = LabelLo + ActionP
	->  format(atom(Action), '\'swipl-win\':~s_~s.\n', [LabelLo, ActionP])
	;   Command = LabelLo * ActionP  % unused, was a shortcut to inline www_open_url()
	->  format(atom(Action), '~q.\n', [ActionP])
	;   Command = LabelLo,
	    format(atom(Action), '\'swipl-win\':~s.\n', [Command])
	),
	sub_atom(LabelLo, Pos, 1, _, Ampersand), Ampersand \= '_',
	\+ memberchk(Ampersand, Accel),
	!, make_label(LabelLo, Pos, Label),
	win_insert_menu_item(Menu, Label, -, Action),
	setup_submenu(Commands, Menu, [Ampersand|Accel]).

:- if(\+current_predicate(win_has_menu/0)).

% just display formatted entries
%
win_insert_menu(Label, Before) :- writeln(win_insert_menu(Label, Before)).
win_insert_menu_item(Pulldown, Label, Before, Goal) :- writeln(win_insert_menu_item(Pulldown, Label, Before, Goal)).

:- else.

%%	consult_query_file
%
%	issue file selection and simpy consult it.
consult_query_file :-
	pqConsole:getOpenFileName('Consult File', _, 'Prolog Source (*.lp *.pl *.pro)', File),
	consult(File).

%%	edit_query_file
%
%	issue file selection, start XPCE and edit it.
%
edit_query_file :-
	pqConsole:getOpenFileName('Edit File', _, 'Prolog Source (*.lp *.pl *.pro)', File),
	load_xpce,
	edit(File).

%%	new_query_file
%
%	prompt for a file name, check existence, start XPCE to edit.
%
new_query_file :-
        pqConsole:getSaveFileName('New File', _, 'Prolog Source (*.lp *.pl *.pro)', File),
        \+ exists_file(File),
	load_xpce,
        edit(file(File)).

%%      help menu
%
about :-
    print_message(informational, about).

console_help :-
    load_xpce,
    help.

browse_pldoc :-
    load_xpce,
    doc_browser.

%%	entries simply loading an URL
%
swi_prolog_website :-	www_open_url('http://www.swi-prolog.org').
manual :-               www_open_url('http://www.swi-prolog.org/pldoc/index.html').
faq :-                  www_open_url('http://www.swi-prolog.org/FAQ/').
quick_start :-          www_open_url('http://www.swi-prolog.org/man/quickstart.html').
mailing_list :-         www_open_url('http://www.swi-prolog.org/Mailinglist.html').
download :-             www_open_url('http://www.swi-prolog.org/Download.html').
extension_packs :-      www_open_url('http://www.swi-prolog.org/pack/list').
submit_bug_report :-    www_open_url('http://www.swi-prolog.org/bugzilla/').

xpce_gui_manual :-
    load_xpce,
    manpce.

%%	new_thread
%
%	from thread_util, this function is able to start an hosted
%	thread with related console
%
new_thread :-
	interactor.

load_xpce :-
	(   current_prolog_flag(xpce, true)
	->  true
	;   (   current_prolog_flag(unix, true)
	    ->  [swi('swipl.rc')]
	    ;	[swi('swipl-win.rc')]
	    ),
	    set_prolog_flag(xpce_threaded, true)
	).

edit_spy_points :- load_xpce, prolog_ide(open_debug_status).
edit_exceptions :- load_xpce, prolog_ide(open_exceptions(@(on))).
monitor_threads :- load_xpce, prolog_ide(thread_monitor).
debug_messages :- load_xpce, prolog_ide(debug_monitor).

navigator_query_uri :-
    load_xpce,
    prolog_ide(open_navigator).

user_init_file :-
    load_xpce,
    prolog_edit_preferences(prolog).
gui_preferences :-
    load_xpce,
    prolog_edit_preferences(xpce).

%%	cross_referencer
%
%	start XPCE, then run cross referencer
%
cross_referencer :-
	load_xpce,
	gxref.

%%	graphical_debugger
%
%	start XPCE, then run the graphical debugger
%
graphical_debugger :-
	load_xpce,
	gtrace.

:- endif.

% run menu setup on consult. pqConsole handles redefinition, if needed.
%
:- initialization(setup_gui, now).
