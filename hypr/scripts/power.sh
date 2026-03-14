#!/usr/bin/env bash

terminate_clients() {
    TIMEOUT=5
    client_pids=$(hyprctl clients -j | jq -r '.[] | .pid' | sort -u)

    for pid in $client_pids; do
        echo ":: Sending SIGTERM to PID $pid"
        kill -15 "$pid" 2>/dev/null || true
    done

    start_time=$(date +%s)
    for pid in $client_pids; do
        while kill -0 "$pid" 2>/dev/null; do
            current_time=$(date +%s)
            elapsed_time=$((current_time - start_time))

            if [ "$elapsed_time" -ge "$TIMEOUT" ]; then
                echo ":: Timeout reached."
                return 0
            fi

            echo ":: Waiting for PID $pid to terminate..."
            sleep 1
        done

        echo ":: PID $pid has terminated."
    done
}

case "$1" in
    exit)
        echo ":: Exit"
        terminate_clients
        sleep 0.5
        hyprctl dispatch exit
        ;;
    lock)
        echo ":: Lock"
        sleep 0.5
        hyprlock
        ;;
    reboot)
        echo ":: Reboot"
        terminate_clients
        sleep 0.5
        systemctl reboot
        ;;
    shutdown)
        echo ":: Shutdown"
        terminate_clients
        sleep 0.5
        systemctl poweroff
        ;;
    suspend)
        echo ":: Suspend"
        sleep 0.5
        systemctl suspend
        ;;
    hibernate)
        echo ":: Hibernate"
        sleep 1
        systemctl hibernate
        ;;
    *)
        echo "Usage: $0 {exit|lock|reboot|shutdown|suspend|hibernate}"
        exit 1
        ;;
esac

