%%%----------------------------------------------------------------------
%%% File    : ejabberd_web.erl
%%% Author  : Alexey Shchepin <alexey@sevcom.net>
%%% Purpose : 
%%% Created : 28 Feb 2004 by Alexey Shchepin <alexey@sevcom.net>
%%% Id      : $Id: ejabberd_web.erl 500 2006-02-06 05:12:54Z alexey $
%%%----------------------------------------------------------------------

-module(ejabberd_web).
-author('alexey@sevcom.net').
-vsn('$Revision: 500 $  ').

%% External exports
-export([make_xhtml/1,
	 process_get/2]).

-include("ejabberd.hrl").
-include("jlib.hrl").
-include("ejabberd_http.hrl").


make_xhtml(Els) ->
    {xmlelement, "html", [{"xmlns", "http://www.w3.org/1999/xhtml"},
			  {"xml:lang", "en"},
			  {"lang", "en"}],
     [{xmlelement, "head", [],
       [{xmlelement, "meta", [{"http-equiv", "Content-Type"},
			      {"content", "text/html; charset=utf-8"}], []}]},
      {xmlelement, "body", [], Els}
     ]}.


-define(X(Name), {xmlelement, Name, [], []}).
-define(XA(Name, Attrs), {xmlelement, Name, Attrs, []}).
-define(XE(Name, Els), {xmlelement, Name, [], Els}).
-define(XAE(Name, Attrs, Els), {xmlelement, Name, Attrs, Els}).
-define(C(Text), {xmlcdata, Text}).
-define(XC(Name, Text), ?XE(Name, [?C(Text)])).
-define(XAC(Name, Attrs, Text), ?XAE(Name, Attrs, [?C(Text)])).

-define(LI(Els), ?XE("li", Els)).
-define(A(URL, Els), ?XAE("a", [{"href", URL}], Els)).
-define(AC(URL, Text), ?A(URL, [?C(Text)])).
-define(P, ?X("p")).
-define(BR, ?X("br")).
-define(INPUT(Type, Name, Value),
	?XA("input", [{"type", Type},
		      {"name", Name},
		      {"value", Value}])).


process_get({_, true},
	    #request{auth = Auth,
		     path = ["admin", "server", SHost | RPath],
		     q = Query,
		     lang = Lang} = Request) ->
    Host = jlib:nameprep(SHost),
    case lists:member(Host, ?MYHOSTS) of
	true ->
	    US = case Auth of
		     {SJID, P} ->
			 case jlib:string_to_jid(SJID) of
			     error ->
				 unauthorized;
			     #jid{user = U, server = S} ->
				 case ejabberd_auth:check_password(U, S, P) of
				     true ->
					 {U, S};
				     false ->
					 unauthorized
				 end
			 end;
		     _ ->
			 unauthorized
		 end,
	    case US of
		{User, Server} ->
		    case acl:match_rule(
			   Host, configure, jlib:make_jid(User, Server, "")) of
			deny ->
			    {401, [], make_xhtml([?XC("h1", "Not Allowed")])};
			allow ->
			    ejabberd_web_admin:process_admin(
			      Host, Request#request{path = RPath,
						    us = US})
		    end;
		unauthorized ->
		    {401,
		     [{"WWW-Authenticate", "basic realm=\"ejabberd\""}],
		     ejabberd_web:make_xhtml([{xmlelement, "h1", [],
					       [{xmlcdata, "401 Unauthorized"}]}])}
	    end;
	false ->
	    {404, [], make_xhtml([?XC("h1", "Not found")])}
    end;

process_get({_, true},
	    #request{auth = Auth,
		     path = ["admin" | RPath],
		     q = Query,
		     lang = Lang} = Request) ->
    US = case Auth of
	     {SJID, P} ->
		 case jlib:string_to_jid(SJID) of
		     error ->
			 unauthorized;
		     #jid{user = U, server = S} ->
			 case ejabberd_auth:check_password(U, S, P) of
			     true ->
				 {U, S};
			     false ->
				 unauthorized
			 end
		 end;
	     _ ->
		 unauthorized
	 end,
    case US of
	{User, Server} ->
	    case acl:match_rule(
		   global, configure, jlib:make_jid(User, Server, "")) of
		deny ->
		    {401, [], make_xhtml([?XC("h1", "Not Allowed")])};
		allow ->
		    ejabberd_web_admin:process_admin(
		      global, Request#request{path = RPath,
					      us = US})
	    end;
	unauthorized ->
	    {401,
	     [{"WWW-Authenticate", "basic realm=\"ejabberd\""}],
	     ejabberd_web:make_xhtml([{xmlelement, "h1", [],
				       [{xmlcdata, "401 Unauthorized"}]}])}
    end;

process_get({true, _},
	    #request{path = ["http-poll" | RPath],
		     q = _Query,
		     lang = _Lang} = Request) ->
    ejabberd_http_poll:process_request(Request#request{path = RPath});

process_get(_, _Request) ->
    {404, [], make_xhtml([?XC("h1", "Not found")])}.


