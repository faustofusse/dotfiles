#!/usr/bin/env nu
niri msg --json event-stream | lines | each { |event|
    print $event
    let record = $event | from json
    let is_open = $record.OverviewOpenedOrClosed?.is_open?
    if $is_open != null {
        let action = if $is_open { "open" } else { "close" }
        try { eww $action bar }
    }
}
