--!strict
local available = false
local active = false

local function applyStatus(status: string)
    if type(status) ~= "table" then
        noctalia.log("Hotspot widget widget: Invalid status")
        return -- status is invalid, don't process it
    end

    available = status.available
    active = status.active

    barWidget.setVisible(status.available)

    if active then
        if barWidget.getConfig("show_label") then
            barWidget.setText(status.ssid)
        end
        barWidget.setGlyph("access-point")
        barWidget.setGlyphColor("primary")
        barWidget.setColor("primary")
        barWidget.setTooltip(`{status.ssid} {if status.band == "a" then "5GHz" else "2.4GHz"} — {status.security}`)
    else
        barWidget.setGlyph("access-point-off")
        barWidget.setGlyphColor("on_surface_variant")
        barWidget.setColor("on_surface_variant")
        barWidget.setText("")
        barWidget.clearTooltip()
    end
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
