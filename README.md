# Progress

Each day I use a different programming language.

## Day 1 - Squirrel

A simple language which does not seem to be developed for a while.
The language has documentation which is sufficient, however it lacks more examples.

The task itself was fairly simple, yet it allowed to look for a better than naive algorithm.

## Day 2 - Sed

It is well-known that sed is a very powerful tool, yet is it up to this task.
It certainly is and thanks to single-letter command names, the solution is even very short.

The task was mostly about organizing the input so that we could work with two consecutive characters.
Working with unary system was crucial and conversion between unary and decimal numbers was tedious.

## Day 3 - TCL

Very powerful minimalistic language; I like its rawness.
It has pretty good documentation with examples.

I was hoping that the second part of the task would be search for minimum over all slopes.
Maybe in some later task...

## Day 4 - D

After an intermezzo trying to learn and later failing to install Self on my 64bit system, I chose D as a language which should be simpler.
D was surprisingly easy; I quite like it, I definitely can it fitting between C and Go.
I could not make it work properly in Idea (https://github.com/intellij-dlanguage/intellij-dlanguage/issues/496),
so I had to look up everything in documentation or tutorials instead of relying on IntelliSense.

Task was easy; the second part had me learn pointers to functions, anonymous function in D which was much nicer than in C.

## Day 5 - Forth

I have read a lot about this minimalistic language, so I wanted to try it.
It is quite interesting to design a stack based program, although it was a mind-fuck from time to time.

The task would have been easy in any language.
The second part was very expected.

## Day 6 - Racket

Lisp/Scheme-like language which has pretty nice editor (`drrocket`), although it could have better integrated documentation.

The task was easily solved after finding out that the language has set operations (union and intersect).
A minor issue was that it does not have `fold1`.

## Day 7 - Bash

This finally forced me to learn bash extensions of Shell: arrays, associative arrays, namerefs.

Graph traversal was easy in the end.
I was worried that there would be cycles present and algorithm would have to be more complex, maybe later.
I remember a similar task from last(?) year. 

## Day 8 - Cobol

Another ancient language crossed from my list, and I don't want to see it ever again.
Cobol is so verbose, so weirdly structured.
I chose it because I dod not need dynamic allocation of memory for this task.

It was mostly about battling the language and reading documentation and forums mentioning mainframes.
I hope there won't bet too many virtual machine tasks as last year.

## Day 9 - SQL

SQL is quite powerful, it is easy to emulate for loops.
Since the input can be considered a CSV, even loading data was easy.
And even better, sqlite can run in memory, so the computation does not need nor leave an existing database.

Fortunately the task was easy enough to be solved using a couple iterations over tables.
The only clever algorithm was to precompute prefix sums.

## Day 10 - Zig

An interesting idea for making a language at the level of C but much safer.
It has a nice concept of error handling.
The doom of the language is documentation of its standard library which is bad: functions are missing or are undocumented.

I could predict the second part and was looking for it.
Dynamic programing made it trivial.

## Day 11 - R

R is relatively pleasant, has decent documentation, and variety of high-level data types.
I had bad experience many years ago with R when we needed to run a simulation, but it was much better this time.
The trick with loading a file as CSV worked again.

Language with vector operation turned to be great for this task.
Apart from initial computation of `sees` matrix, the core functions `iter` and `conv` are ridiculously simple.

## Day 12 - Vim Script

Vim Script is good enough for its purpose, but nothing exciting to work with.
It is interesting to mix the modes, interacting with the editor from the script.

The task was simple so a single pass through the input data was enough.
Most of the work was then making vim print to terminal and quit.

## Day 13 - Crystal

A compilable Ruby.
It has quite a bit chaotic documentation of the language but a usable documentation of the standard library (looking at you Zig).
Luckily the language supports easy work with big numbers.

I was looking forward to some number theory.
The task is easy once it is clear once restarted in modular arithmetics.

## Day 14 - Perl

Again a language which I was a bit familiar with.
I am quite uncomfortable with Perl; it does not have proper parameters of subs, it has contexts, different comparison operators for numbers and strings.  

When implementing the second part I was a bit worried that the memory won't be sufficient and a different representation would be necessary.

## Day 15 - Red

Red is a pretty ugly language and inherits it from Rebol.
The documentation is not terrible but naming array access words `pick` and `poke` makes them hard to find.

I assumed that I will need to keep information about number's last position instead of always searching again.
Even that however was not enough to run at a reasonable speed (the task takes 35 seconds).

## Day 16 - Mercury

Mercury is very similar to Prolog, just has more options and is safer.
The documentation is pretty good, maybe could have more examples.
I spent most of the time fighting the language rather than the solving the task.

The second part could have been harder, I was preparing to implement all-distinct predicate using some advanced techniques, but that was not needed.
Overall nice task, but way too much parsing using language which is not meant for it (if this was two days ago...)

## Day 17 - Eiffel

Eiffel is very interesting language; it has features which are later available in Java.
I even quite liked the syntax, just commas were problematic.

Game of Life in multiple dimensions - rather easy but hard to generalize to variable number of dimensions without huge repeats in the code. 
The language seems slow as the task took 47 seconds.

## Day 18 - PostScript

PostScript is another of old languages; it is pretty comfortable to work with it.
I missed more commands for operations with the stack (like Forth has).
It does not have a great documentation; this is the best list of commands that I found: http://www.math.ubc.ca/~cass/courses/ps.html

The task was interesting.
The stack-based language was a good fit for it.
The second part was not very hard but revealed couple errors.

## Day 19 - Objective-C

Objective-C is weird, it is like two languages with different syntax.
Objective part uses brackets, colons and no commas.

The task was harder than it looked.
If only I could use Prolog, it would all be much easier.
The hardest part was to implement restart (failures) while proceeding in matching.

## Day 20 - Vala

Some say that Vala is not a real language because it just wraps C and Glib.
Nevertheless, it is very comfortable to program in it as it has a nice high-level modern syntax based on C#.  

This task was different because it needed implementation of many steps:  parsing, corner finding, orientating, stitching, monster finding.
I am happy that I chose an easy language and spent time on the algorithms rater than fighting the syntax.

## Day 21 - C++

C++ is as good/bad as it always was.
I was surprised I did not encounter any segfaults, but that is probably because of preferring references in most places.
The standard library is evolving slowly, but it stills lacks trivial operations such as splitting a string.

The task was easy enough once I started parsing the input.
I intended to go object oriented way with modeling the task with classes - that is still there.
However, during input parsing, it was too tempting to run some intersection and deduplication and by mistake solve the second task before the first one.

# Language Pool

* Genie
* Joy
* Scratch
* Swift
* TeX
* TypeScript

# Banned

* Self - does not have 64bit distribution
* XQuery - not powerful enough
* Pony - ld: unrecognised emulation mode: cx16
* Oberon - not exactly a language, it is an operating system
* Java - JVM languages will be next year
* Scala - JVM languages will be next year
* Goby - Does not have documentation (404)
* Smalltalk - Could start GUI but could not do anything; poor documentation maybe
