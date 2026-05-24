#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Use: $0 /path/to/wallpaper [shader_path] [monitor_target]"
	exit 1
fi

WALLPAPER="$1"
SHADER="$2"
MONITOR="${3:-ALL}"

# Kill existing mpvpaper instances for this specific monitor
# Use the IPC socket as a unique identifier since it contains the monitor name
SOCKET="/tmp/ambxst_mpv_socket_${MONITOR}"

# Find and kill mpvpaper processes associated with this monitor/socket
pgrep -x mpvpaper 2>/dev/null | while read -r pid; do
	cmdline=$(ps -p "$pid" -o args= 2>/dev/null)
	# Kill if it's running on the same monitor OR using the same socket
	if echo "$cmdline" | grep -q " $MONITOR$\| $MONITOR \|input-ipc-server=$SOCKET"; then
		kill "$pid" 2>/dev/null
		# Wait briefly for graceful exit
		sleep 0.2
		# Force kill if still running
		kill -9 "$pid" 2>/dev/null
	fi
done

MPV_OPTS="no-audio loop hwdec=auto vo=gpu-next profile=fast interpolation=no video-sync=display-resample panscan=1.0 load-scripts=no input-ipc-server=$SOCKET cache-pause=no"

# If shader is provided and file exists, add it to MPV_OPTS
if [ -n "$SHADER" ] && [ -f "$SHADER" ]; then
	MPV_OPTS="$MPV_OPTS glsl-shaders=\"$SHADER\""
fi

exec mpvpaper -o "$MPV_OPTS" "$MONITOR" "$WALLPAPER"
