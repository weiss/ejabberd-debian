%%%----------------------------------------------------------------------
%%% File    : ejabberd_http.hrl
%%% Author  : Alexey Shchepin <alexey@sevcom.net>
%%% Purpose : 
%%% Created :  4 Mar 2004 by Alexey Shchepin <alexey@sevcom.net>
%%% Id      : $Id: ejabberd_http.hrl 307 2005-04-17 18:08:34Z tmallard $
%%%----------------------------------------------------------------------

-record(request, {method,
		  path,
		  q = [],
		  us,
		  lang = "",
		  data = ""
		 }).


