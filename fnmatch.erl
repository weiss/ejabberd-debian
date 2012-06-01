-module(fnmatch).
-compile(export_all).
-import(lists, [reverse/1]).

sh(Pattern) when is_list(Pattern) ->
    sh_char(Pattern, [$(,$^]).

sh_char([], Acc) ->
    lists:reverse([$$,$)|Acc]);
sh_char([Ch|Tail], Acc) ->
    case Ch of
	$\\ ->
	    sh_char(Tail, [$\\,$\\|Acc]);
	$[ ->
	    sh_bexp_first(Tail, [Ch|Acc]);
	$? ->
	    sh_char(Tail, [$.|Acc]);
	$* ->
	    sh_char(Tail, [$*,$.|Acc]);
	_ ->
	    case lists:member(Ch, "^.+{}()$|\\") of
		true ->
		    sh_char(Tail, [Ch,$\\|Acc]);
		false ->
		    sh_char(Tail, [Ch|Acc])
	    end
    end.

sh_bexp_first([], _) ->
    {error, unclosed_be};
sh_bexp_first([Ch|Tail], Acc) ->
    case Ch of
	$] ->
	    {error, empty_be};
	$! ->
	    sh_bexp_next(Tail, false, [$^|Acc]);
	$\\ ->
	    sh_bexp_next(Tail, true, Acc);
	_ ->
	    sh_bexp_next(Tail, false, [Ch|Acc])
    end.

sh_bexp_next([], _, _) ->
    {error, unclosed_be};
sh_bexp_next([Ch|Tail], true, Acc) ->
    sh_bexp_next(Tail, false, [Ch,$\\|Acc]);
sh_bexp_next([Ch|Tail], false, Acc) ->
    case Ch of
	$] ->
	    sh_char(Tail, [Ch|Acc]);
	$\\ ->
	    sh_bexp_next(Tail, true, Acc);
	_ ->
	    sh_bexp_next(Tail, false, [Ch|Acc])
    end.

test() ->
    ok.

%% vim:ts=8:sw=4:sts=4:noet
