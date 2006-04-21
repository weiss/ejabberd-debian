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

status()
{
    $EJABBERDCTL status >/dev/null
}

start()
{
    cd /var/lib/ejabberd
    su $EJABBERDUSER -c "$EJABBERD -noshell -detached"
}

case "$1" in
    start)
	echo -n "Starting jabber server: $NAME"
	if status
	then
	    echo " already running."
	    false
	else
	    start
	fi
    ;;
    stop)
	echo -n "Stopping jabber server: $NAME"
	if $EJABBERDCTL stop
	then
	    cnt=0
	    while status
	    do
		cnt=`expr $cnt + 1`
		if [ $cnt -gt 60 ]
		then
		    echo -n " failed"
		    break
		fi
		sleep 1
		echo -n .
	    done
	else
	    echo -n " failed"
	fi
	true
    ;;
    restart|force-reload)
	echo -n "Restarting jabber server: $NAME"
	if status
	then
	    $EJABBERDCTL restart
	else
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
	exit 0
else
	echo "failed."
	exit 1
fi
