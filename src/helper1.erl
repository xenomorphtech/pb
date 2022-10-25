-module(helper1).
-compile(no_auto_import).

-export([f_bsl/2, f_band/2, f_bsr/2]).


f_bsl(A,B) ->
  erlang:'bsl'(A, B).
f_band(A,B) ->
  erlang:'band'(A, B).
f_bsr(A,B) ->
  erlang:'bsr'(A, B).

