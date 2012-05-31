-module(fnmatch).
-compile(export_all).
-import(lists, [reverse/1]).

escape(Pattern) when is_list(Pattern) ->
	escape(Pattern, []).

escape([], Acc) ->
	lists:reverse(Acc);
escape([Ch|Tail], Acc) ->
	case lists:member(Ch, "^.?*+{}()[]$|\\") of
		true ->
			escape(Tail, [Ch,$\\|Acc]);
		false ->
			escape(Tail, [Ch|Acc])
	end.

sh(Pattern) when is_list(Pattern) ->
	sh(char, Pattern, []).

sh(char, [], Acc) ->
	lists:reverse(Acc);
sh(char, [Ch|Tail], Acc) ->
	case Ch of
		$[ ->
			sh(bexp_first, Tail, [Ch|Acc]);
		$? ->
			sh(char, Tail, [Ch,$.|Acc]);
		$* ->
			sh(char, Tail, [Ch,$.|Acc]);
		_ ->
			case lists:member(Ch, "^.+{}()$|\\") of
				true ->
					sh(char, Tail, [Ch,$\\|Acc]);
				false ->
					sh(char, Tail, [Ch|Acc])
			end
	end;
sh(bexp_first, [], _) ->
	{error, unclosed_be};
sh(bexp_first, [Ch|Tail], Acc) ->
	case Ch of
		$] ->
			{error, empty_be};
		$! ->
			sh(bexp_next, Tail, [$^|Acc]);
		_ ->
			sh(bexp_next, Tail, [Ch|Acc])
	end;
sh(bexp_next, [], _) ->
	{error, unclosed_be};
sh(bexp_next, [Ch|Tail], Acc) ->
	State = case Ch of
		$] ->
			char;
		_ ->
			bexp_next
	end,
	sh(State, Tail, [Ch|Acc]).

test() ->
	ok.

