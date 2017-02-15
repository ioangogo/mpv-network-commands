-- Purpose is to listen on a defined port for commands to pass to mpv

local port = 82312

local socket = require("socket")
local conn = socket.tcp();

conn:setsockname("*", port);
conn:settimeout(0);

-- commands to add: 
--   FORWARD/BACK N - jump forward/back 5/10/30/60/n seconds
--   FORWARDX/BACKX N - fastforward/rewind 1/4, 1/3, 1/2, 3/2, 2, 3, 4, n times as fast
--   NEXTCHAP/PREVCHAP - jump chapter forward/back
--   NEXT/PREV - jump file forward/back (in playlist)
--   START/END - start/end
--   SET A/V/S N - use N'th audio/sub/vid track
--   VOLUME N - set volume
local commands = {
    {"PAUSE", "set pause yes"},
    {"PLAY", "set pause no"},
    {"TPAUSE", "cycle pause"},
    {"TPLAY", "cycle pause"},
    {"FORWARD", "seek 5"},
    {"BACK", "seek -5"},
    {"STEP", "frame_step"},
    {"STEPBACK", "frame_step_back"},
    {"MUTE", "cycle mute"},
    {"VOLUME UP", "add volume 5"},
    {"VOLUME DOWN", "add volume -5"},
    {"VOLUME MAX", "set volume 100"},
    {"CYCLE A", "cycle aid"},
    {"CYCLE V", "cycle vid"},
    {"CYCLE S", "cycle sid"},
    {"FULLSCREEN", "set fullscreen yes"},
    {"WINDOWED", "set fullscreen no"},
    {"TFULLSCREEN", "cycle fullscreen"},
    {"TWINDOWED", "cycle fullscreen"},
    {"QUIT", "quit"}
}

function do_things(data)
    -- search table for matching command
    for n, ent in pairs(commands) do
        if (data == ent[1]) then
            mp.command(ent[2]);
            return;
        end
    end
    mp.osd_message("Got " .. data);
end

-- maybe figure out how to set this up with a non-blocking select instead of polling the socket constantly
function check_socket()
    while 1 do
  -- wait for a connection from any client
      local client = server:accept()
  -- make sure we don't block waiting for this client's line
      client:settimeout(0)
  -- receive the line
      local line, err = client:receive()
      if (line ~= nil) then
        -- do things with data
        do_things(line);
        end
  -- if there was no error, send it back to the client
      if not err then client:send(line .. "\n") end
  -- done with client, close the object
  --client:close()
    end
end

check_socket

function cleanup(event)
    conn:close();
end

mp.register_event("shutdown", cleanup);
