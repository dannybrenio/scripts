#!/bin/bash

case "$1" in
    start)
        echo "Starting LAMPP..."
        sudo /opt/lampp/lampp start
        ;;
    stop)
        echo "Stopping LAMPP..."
        sudo /opt/lampp/lampp stop
        ;;
    restart)
        echo "Restarting LAMPP..."
        sudo /opt/lampp/lampp restart
        ;;
    status)
        sudo /opt/lampp/lampp status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac


