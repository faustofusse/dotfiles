local mp = require('mp')
local os = require('os')

local function exec(cmd)
    local handle = io.popen(cmd .. ' 2>&1')
    if not handle then return nil end
    local result = handle:read('*a')
    handle:close()
    return result
end

local function command_exists(cmd)
    local result = exec('command -v ' .. cmd)
    return result and result:match('%S') ~= nil
end

local function screenshot_to_clipboard()
    -- Use a clean temp path (os.tmpname() creates a file, so we avoid it)
    local tmp_path = '/tmp/mpv_screenshot_' .. os.time() .. '_' .. math.random(10000, 99999) .. '.png'

    -- mpv screenshot-to-file command takes: screenshot-to-file <filename> [subtitles]
    mp.command_native({'screenshot-to-file', tmp_path})

    local platform = mp.get_property_native('platform')

    if platform == 'darwin' then
        -- macOS: use osascript
        local cmd = string.format(
            'osascript -e \'set the clipboard to (read (POSIX file "%s") as picture)\'',
            tmp_path
        )
        local result = exec(cmd)
        if result and result:match('error') then
            mp.osd_message('Clipboard error: ' .. result, 3)
            os.remove(tmp_path)
            return
        end
    else
        -- Linux
        local is_wayland = os.getenv('WAYLAND_DISPLAY') ~= nil
        if is_wayland and command_exists('wl-copy') then
            local cmd = string.format('wl-copy --type image/png < "%s"', tmp_path)
            os.execute(cmd)
        elseif command_exists('xclip') then
            local cmd = string.format('xclip -selection clipboard -t image/png -i "%s"', tmp_path)
            os.execute(cmd)
        else
            mp.osd_message('Error: wl-copy or xclip not found', 3)
            os.remove(tmp_path)
            return
        end
    end

    os.remove(tmp_path)
    mp.osd_message('Screenshot copied to clipboard', 2)
end

mp.add_key_binding('Ctrl+Shift+s', 'screenshot-clipboard', screenshot_to_clipboard)
