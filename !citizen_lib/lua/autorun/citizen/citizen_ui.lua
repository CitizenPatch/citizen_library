citizen.draw = {}
citizen.draw.Storage = {}
local uiMeta = {}
uiMeta.__index = uiMeta

function citizen.draw.Register(name, func)
    name = 'citizen_' .. name

    local obj = {
        name = name,
        painting = func,
        Alternative = false,
    }

    citizen.Log(string.format('citizen_ui.lua: Created UI ^: %s :^', name))
    setmetatable(obj, uiMeta)
    citizen.draw.Storage[name] = obj

    return obj
end

function citizen.draw.Remove(name)
    citizen.draw.Storage[name]:Remove()
end

function uiMeta:Draw()
    hook('HUDPaint', self.name, function()
        local sw, sh = ScrW(), ScrH()
        self.painting(sw, sh)
    end)
end

function uiMeta:AlternativeMethod()
    hook.Remove('HUDPaint', self.name)
    self.Alternative = true
    
    hook('PostRender', self.name, function()
        cam.Start2D()
            local sw, sh = ScrW(), ScrH()
            self.painting(sw, sh)
        cam.End2D()
    end)
end

function uiMeta:Remove()
    citizen.Log('UI With UID ' .. self.name .. ' was removed')
    hook.Remove('HUDPaint', self.name)
end