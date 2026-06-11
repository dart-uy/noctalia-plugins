local pluginDir = noctalia.pluginDir()
local initScript = pluginDir .. "/init.sh"

local device = noctalia.getConfig("device")
local ssid = noctalia.getConfig("ssid")
local security = noctalia.getConfig("security")
local password = noctalia.getConfig("password")
local band = noctalia.getConfig("band")
local channel = if band == "a" then noctalia.getConfig("a-channel") else noctalia.getConfig("bg-channel")
local channel_width = noctalia.getConfig("channel-width")

local active = false
local available = false

local function publishStatus()
    noctalia.state.set("status", {
        device = device,
        ssid = ssid,
        security = security,
        band = band,
        channel = channel,
        active = active,
        available = available
    })
end

local function toggle(action: string)
    noctalia.runAsync("nmcli c " .. action .. " Hotspot", function(result)
        if result.exitCode ~= 0 then
            noctalia.notifyError("Hotspot plugin", "Can't turn " .. action .. " Hotspot")
            return
        end
        active = not active
        publishStatus()
    end)
end

local function initHotspot()
    if not noctalia.commandExists("nmcli") or not noctalia.commandExists("awk") then
        noctalia.notifyError("Hotspot plugin", "Hotspot can't be initialized. Are you running NetworkManager?")
        return
    end
    noctalia.runAsync(`bash {initScript} {device} {ssid} {password} {security} {band} {channel} {channel_width}`, function(result)
        if result.exitCode == 1 or result.exitCode == 2 then
            available = false
            return
        end
        available = true
        if result.exitCode == 0 then
            active = true
        elseif result.exitCode == 3 then
            toggle("up")
        end
        publishStatus()
    end)
end

function onIpc(event, payload)
    if event == "on" then
        toggle("up")
    elseif event == "off" then
        toggle("down")
    else
        noctalia.log("hotspot plugin: unknown command '" .. tostring(event) .. "'")
    end
end

noctalia.state.watch("command", function(cmd)
    local action = (type(cmd) == "table" and cmd.action) or cmd
    if type(action) == "string" then
        onIpc(action, nil)
    end
end)

initHotspot()
