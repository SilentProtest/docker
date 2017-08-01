#!/usr/bin/liquidsoap

# Documentation:
# http://liquidsoap.fm/doc-dev/quick_start.html
# http://liquidsoap.fm/doc-dev/complete_case.html
# http://liquidsoap.fm/doc-dev/cookbook.html

# print log messages to the console,
set("log.stdout", true)
# don't use the telnet server for requests
set("server.telnet", false)

# backup stream if nobody is live streaming
backup_stream = mksafe(playlist("/media/"))

# primary input is icecast from DJ
live_stream = input.http(buffer=0.5,max=1.0,timeout=5.0,"http://stream_icecast:8000/dj")

# if live stream is down, use backup_stream
full_stream = fallback(track_sensitive=false, [live_stream, backup_stream])

# mono
full_stream = mean(full_stream)

# clean transitions
full_stream = smart_crossfade(start_next=0.5, full_stream)

# transcode to mp3 and send to icecast
output.icecast(%mp3(bitrate=128, stereo=false), 
  host="stream_icecast", port=8000, password="love",
  mount="live", timeout=5.0, full_stream)
