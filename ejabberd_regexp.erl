-module(ejabberd_regexp).
-import(lists, [reverse/1]).
-export([sh_to_awk/1]).

sh_to_awk(Pattern) when is_list(Pattern) ->
    fnmatch_char(Pattern, [$(,$^]).

fnmatch_char([], Acc) ->
    lists:reverse([$$,$)|Acc]);
fnmatch_char([Ch|Tail], Acc) ->
    case Ch of
	$\\ ->
	    fnmatch_char(Tail, [$\\,$\\|Acc]);
	$[ ->
	    fnmatch_bexp_first(Tail, [Ch|Acc]);
	$? ->
	    fnmatch_char(Tail, [$.|Acc]);
	$* ->
	    fnmatch_char(Tail, [$*,$.|Acc]);
	_ ->
	    case lists:member(Ch, "^.+{}()$|\\") of
		true ->
		    fnmatch_char(Tail, [Ch,$\\|Acc]);
		false ->
		    fnmatch_char(Tail, [Ch|Acc])
	    end
    end.

fnmatch_bexp_first([], _) ->
    {error, unclosed_be};
fnmatch_bexp_first([Ch|Tail], Acc) ->
    case Ch of
	$] ->
	    {error, empty_be};
	$! ->
	    fnmatch_bexp_next(Tail, false, [$^|Acc]);
	$\\ ->
	    fnmatch_bexp_next(Tail, true, Acc);
	_ ->
	    fnmatch_bexp_next(Tail, false, [Ch|Acc])
    end.

fnmatch_bexp_next([], _, _) ->
    {error, unclosed_be};
fnmatch_bexp_next([Ch|Tail], true, Acc) ->
    fnmatch_bexp_next(Tail, false, [Ch,$\\|Acc]);
fnmatch_bexp_next([Ch|Tail], false, Acc) ->
    case Ch of
	$] ->
	    fnmatch_char(Tail, [Ch|Acc]);
	$\\ ->
	    fnmatch_bexp_next(Tail, true, Acc);
	_ ->
	    fnmatch_bexp_next(Tail, false, [Ch|Acc])
    end.

%% vim:ts=8:sw=4:sts=4:noet
