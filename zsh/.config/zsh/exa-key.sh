#!/bin/sh
# Fetch EXA_API_KEY from macOS keychain and export it.
# Used by exa-search / exa-contents agent skills.
# Key is stored via: security add-generic-password -a "$USER" -s EXA_API_KEY -w <key>
key=$(security find-generic-password -s EXA_API_KEY -w 2>/dev/null)
if [ -n "$key" ]; then
  export EXA_API_KEY="$key"
fi
