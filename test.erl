-module(test).
-compile(export_all).
-import(lists).

test() ->
	lists:foreach(fun({Pattern, Res}) ->
				Orig = xmerl_regexp:sh_to_awk(Pattern),
				New = ejabberd_regexp:sh_to_awk(Pattern),
				case Res of
					true ->
						case Orig == New of
							true ->
								ok;
							false ->
								io:format("FAILED: for ~p, ~p =/= ~p~n",
									[Pattern, Orig, New])
						end;
					{That, This} ->
						case That == Orig of
							true ->
								ok;
							false ->
								io:format("ORIG FAILED: for ~p, ~p =/= ~p~n",
									[Pattern, That, Orig])
						end,
						case This == New of
							true ->
								ok;
							false ->
								io:format("NEW FAILED: for ~p, ~p =/= ~p~n",
									[Pattern, This, New])
						end
				end
		end, [
			{"", true},
			{"aaa", true},
			{"?", true},
			{"*", true},
			{"*?", true},
			{"?*", true},
			{"a?b*c", true},
			{"[a-z]", true},
			{"[0-9]", true},
			{"[!0-9]", true},
			{"^hey|\\z(xxx)$", true},
			{"\\a[\\bc]\\z", true},
			{"a[0-9]{4}", {"^(a[0-9]{4})$", "^(a[0-9]\\{4\\})$"}},
			{"a[0-", {"^(a[0-)$", {error, unclosed_be}}},
			{"[0\\[]", true},
			{"[0\\]]", {"^([0\\]\\])$", "^([0\\]])$"}},
			{"]", {"^(\\])$", "^(])$"}},
			{"[]", {"^([])$", {error, empty_be}}}
		]).

