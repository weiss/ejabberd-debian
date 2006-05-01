#! /bin/sh
#
# ejabberd        Start/stop ejabberd server
#
#

PATH=/sbin:/bin:/usr/sbin:/usr/bin
EJABBERD=/usr/sbin/ejabberd
EJABBERDCTL=/usr/sbin/ejabberdctl
EJABBERDUSER=ejabberd
NAME=ejabberd

test -f $EJABBERD || exit 0
test -f $EJABBERDCTL || exit 0

# Include ejabberd defaults if available
if [ -f /etc/default/ejabberd ] ; then
    . /etc/default/ejabberd
fi

ctl()
{
    action="$1"
    su $EJABBERDUSER -c "$EJABBERDCTL $action" >/dev/null
}

start()
{
    cd /var/lib/ejabberd
    su $EJABBERDUSER -c "$EJABBERD -noshell -detached"
}

case "$1" in
    start)
	echo -n "Starting jabber server: $NAME"
	if ctl status ; then
	    echo -n " already running"
	else
	    start
	fi
    ;;
    stop)
	echo -n "Stopping jabber server: $NAME"
	if ctl status ; then
	    if ctl stop ; then
		cnt=0
		sleep 1
		while ctl status ; do
		    echo -n .
		    cnt=`expr $cnt + 1`
		    if [ $cnt -gt 60 ] ; then
			echo -n " failed"
			break
		    fi
		    sleep 1
		done
	    else
		echo -n " failed"
	    fi
	else
	    echo -n " already stopped"
	fi
    ;;
    restart|force-reload)
	echo -n "Restarting jabber server: $NAME"
	if ctl status ; then
	    ctl restart
	else
	    echo -n " is not running. Starting $NAME"
	    start
	fi
    ;;
    *)
	echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload}" >&2
	exit 1
    ;;
esac

if [ $? -eq 0 ]; then
    echo .
else
    echo " failed."
fi

exit 0

