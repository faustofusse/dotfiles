#!/usr/bin/env osascript

on is_running(appName)
  tell application "System Events" to (name of processes) contains appName
end is_running

on run argv

  set msg to "Use the following commands:\n"
  set msg to msg & "  isrunning                         - Check if Spotify.app is running"
  set msg to msg & "  start, play [uri]                 - Start playback / play uri\n"
  set msg to msg & "  start, play track  [song name]    - Search and play track\n"
  set msg to msg & "  start, play artist [artist name]  - Search and play artist\n"
  set msg to msg & "  start, play album  [album name]   - Search and play album\n"
  set msg to msg & "  pause, stop                       - Stop playback\n"
  set msg to msg & "  play/pause                        - Toggle playback\n"
  set msg to msg & "  next                              - Next track\n"
  set msg to msg & "  previous, prev                    - Previous track\n"
  set msg to msg & "  info                              - Print track info\n"
  set msg to msg & "  jump N                            - Jump to N seconds in the song\n"
  set msg to msg & "  forward N                         - Jump N seconds forwards\n"
  set msg to msg & "  rewind N                          - Jump N seconds backwards\n"
  set msg to msg & "  shuffle                           - Toggle shuffle\n"
  set msg to msg & "  repeat                            - Toggle repeat\n"
  set msg to msg & "  volume N, up, down                - Set Volume to N (0...100)\n"
  set msg to msg & "  increasevolume N                  - Increment Volume by N (0...100)\n"
  set msg to msg & "  decreasevolume N                  - Decrement Volume by N (0...100)\n"

  set waitFlag to false 

  if count of argv is equal to 0 then
    return msg
  end if
  set command to item 1 of argv
  using terms from application "Spotify"
    set info to "Error."
    -- Is Running
    if command is equal to "isrunning" then
        return is_running("Spotify")
    -- Play
    else if command is equal to "play" or command is equal to "start" then
      if count of argv is equal to 1 then
        tell application "Spotify" to play
      else
        set m_type to item 2 of argv
        set uri to m_type
        set modes to {"artist", "album", "track"}
        if modes contains m_type then
          if count of argv is equal to 2 then
            return "Search argument is missing..."
          else
            set q to ""
            repeat with myArgv from 3 to (count of argv)
                set q to q & item myArgv of argv & " "
            end repeat
            log "Searching " & m_type & "s for " & q
            set spotifySearchAPI to "\"https://api.spotify.com/v1/search\""
            try
              set uri to do shell script  " curl s -G " & spotifySearchAPI & ¬
                                          " --data-urlencode \"q=" & q & "\"" & ¬
                                          " -d \"type=" & m_type & "&limit=1&offset=0\"" & ¬
                                          " -H \"Accept: application/json\" | grep -E -o \"spotify:" & ¬
                                          m_type & ":[a-zA-Z0-9]+\" -m 1"
            on error
              return "No results found for " & q
            end try
            log q & "is Found!"
            set waitFlag to true
          end if
        end if
        tell application "Spotify" to play track uri
      end if
    -- Play/Pause 
    else if command is equal to "play/pause" then
      tell application "Spotify" to playpause
      return "Toggled."
    -- Pause
    else if command is equal to "pause" or command is equal to "stop" then
      tell application "Spotify" to pause
      return "Paused."
    -- Next
    else if command is equal to "next" then
      tell application "Spotify" to next track
    -- Prev
    else if command is equal to "previous" or command is equal to "prev" then
      tell application "Spotify" to previous track
    -- Jump
    else if command is equal to "jump"
      set jumpTo to item 2 of argv as real
      tell application "Spotify"
        set tMax to duration of current track
        if jumpTo > tMax
          return "Can't jump past end of track."
        else if jumpTo < 0
          return "Can't jump past start of track."
        end if
        set nM to round (jumpTo / 60) rounding down
        set nS to round (jumpTo mod 60) rounding down
        set newTime to nM as text & "min " & nS as text & "s"
        set player position to jumpTo
        return "Jumped to " & newTime
      end tell
    -- Forward
    else if command is equal to "forward"
      set jump to item 2 of argv as real
      tell application "Spotify"
        set now to player position
        set tMax to duration of current track
        set jumpTo to now + jump
        if jumpTo > tMax
          return "Can't jump past end of track."
        else if jumpTo < 0
          set jumpTo to 0
        end if
        set nM to round (jumpTo / 60) rounding down
        set nS to round (jumpTo mod 60) rounding down
        set newTime to nM as text & "min " & nS as text & "s"
        set player position to jumpTo
        return "Jumped to " & newTime
      end tell
    -- Rewind
    else if command is equal to "rewind"
      set jump to item 2 of argv as real
      tell application "Spotify"
        set now to player position
        set tMax to duration of current track
        set jumpTo to now - jump
        if jumpTo > tMax
          return "Can't jump past end of track."
        else if jumpTo < 0
          set jumpTo to 0
        end if
        set nM to round (jumpTo / 60) rounding down
        set nS to round (jumpTo mod 60) rounding down
        set newTime to nM as text & "min " & nS as text & "s"
        set player position to jumpTo
        return "Jumped to " & newTime
      end tell
    -- Volume
    else if command is equal to "volume" then
      tell application "Spotify" to set lastVolume to sound volume
      if item 2 of argv as text is equal to "up" then
        set newVolume to lastVolume + 10
      else if item 2 of argv as text is equal to "down" then
        set newVolume to lastVolume - 10
      else
        set newVolume to item 2 of argv as real
      end if  
      if newVolume < 0 then set newVolume to 0
      if newVolume > 100 then set newVolume to 100
      tell application "Spotify"
        set sound volume to newVolume
      end tell
      delay 0.1
      return "Changed volume to " & newVolume
    -- IncreaseVolume
    else if command is equal to "increasevolume" then
      set volumeInc to item 2 of argv as real
      tell application "Spotify"
        set currentVolume to sound volume
        set newVolume to currentVolume + volumeInc
        if newVolume < 0 then set newVolume to 0
        if newVolume > 100 then set newVolume to 100
        set sound volume to newVolume
      end tell
      return "Changed volume to " & newVolume
    -- Decrease Volume
    else if command is equal to "decreasevolume" then
      set volumeInc to item 2 of argv as real
      tell application "Spotify"
        set currentVolume to sound volume
        set newVolume to currentVolume - volumeInc
        if newVolume < 0 then set newVolume to 0
        if newVolume > 100 then set newVolume to 100
        set sound volume to newVolume
      end tell
      return "Changed volume to " & newVolume
    -- Shuffle
    else if command is equal to "shuffle" then
      if count of argv is equal to 2 then
        if item 2 of argv is equal to "on" then
          tell application "Spotify"
            set shuffling to true
            delay 0.1
            return "Shuffle is now " & shuffling
          end tell
        else if item 2 of argv is equal to "off" then
          tell application "Spotify"
            set shuffling to false
            delay 0.1
            return "Shuffle is now " & shuffling
          end tell
        end if
      else
        tell application "Spotify"
          set shuffling to not shuffling
          delay 0.1
          return "Shuffle is now " & shuffling
        end tell
      end if
      
    -- Repeat
    else if command is equal to "repeat" then
      if count of argv is equal to 2 then
        if item 2 of argv is equal to "on" then
          tell application "Spotify"
            set repeating to true
            delay 0.1
            return "Repeat is now " & repeating
          end tell
        else if item 2 of argv is equal to "off" then
          tell application "Spotify"
            set repeating to false
            delay 0.1
            return "Repeat is now " & repeating
          end tell
        end if
      else
        tell application "Spotify"
          set repeating to not repeating
          delay 0.1
          return "Repeat is now " & repeating
        end tell
      end if
      
    -- Info
    else if command is equal to "info" then
      tell application "Spotify"
        set myTrack to name of current track
        set myArtist to artist of current track
        set myAlbum to album of current track
        set tM to round ((duration of current track / 1000) / 60) rounding down
        set tS to round ((duration of current track / 1000) mod 60) rounding down
        set myTime to tM as text & "min " & tS as text & "s"
        set nM to round (player position / 60) rounding down
        set nS to round (player position mod 60) rounding down
        set nowAt to nM as text & "min " & nS as text & "s"
        set info to "Current track:"
        set info to info & "\n Artist:   " & myArtist
        set info to info & "\n Track:    " & myTrack
        set info to info & "\n Album:    " & myAlbum
        set info to info & "\n URI:      " & spotify url of current track
        set info to info & "\n Duration: " & mytime & " ("& (round ((duration of current track / 1000)) rounding down) & " seconds)"
        set info to info & "\n Now at:   " & nowAt
        set info to info & "\n Player:   " & player state
        set info to info & "\n Volume:   " & sound volume
        if shuffling then set info to info & "\n Shuffle is on."
        if repeating then set info to info & "\n Repeat is on."
      end tell
      return info
    else
      log "\nCommand not recognized!\n"
      return msg
    end if

    tell application "Spotify"
      delay 0.1
      repeat while waitFlag
        set nS to round (player position / 1) rounding down
        if nS as text is less than 3 then
          set waitFlag to false
        end if
      end repeat
      set shuf to ""
      set rpt to ""
      if shuffling then 
        set shuf to "\n[shuffle on]"
        if repeating then set rpt to "[repeat on]"
      else
        if repeating then set rpt to "\n[repeat on]"
      end if
      if player state as text is equal to "playing"
        return "Now playing: " & artist of current track & " - " & name of current track & shuf & rpt
      end if
    end tell
  end using terms from
end run

