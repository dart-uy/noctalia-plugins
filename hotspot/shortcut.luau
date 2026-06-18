--!strict
--
local active = false
local available = false

local function applyStatus(status)
    if type(status) ~= "table" then
        noctalia.log("Hotspot plugin shortcut: Invalid status")
        return -- status is invalid, don't process it
    end

    available = status.available
    active = status.active

    shortcut.setLabel(if active then status.ssid else "Hotspot")
    shortcut.setIcon("access-point", "access-point-off")
    shortcut.setActive(active)
    shortcut.setEnabled(available)
end

local function send(action)
    noctalia.state.set("command", action)
end

function onClick()
    if not available then return end
    send(active and "on" or "off")
end

applyStatus(noctalia.state.get("status"))
noctalia.state.watch("status", applyStatus)
