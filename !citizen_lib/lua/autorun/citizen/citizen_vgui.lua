local PANEL = FindMetaTable('Panel')

function citizen.CreateUI(panel, callback, parent)
    local v = vgui.Create(panel, parent)
    callback(v)

    return v
end

function PANEL:SetCloseButton(k)
    if istable(k) then
        for key in ipairs(k) do
            function self:OnKeyCodePressed(c)
                if !self.Initing and code == key then
                    self:RemoveAnimation()
                end  
            end
        end
    else
        function self:OnKeyCodeReleased(c)
            if !self.Initing and c == k then
                self:RemoveAnimation()
            end
        end
    end
end

function PANEL:Pos(x, y)
    self:SetPos(citizen.Scale(x), citizen.Scale(y))
end

function PANEL:Size(w, h)
    self:SetSize(citizen.Scale(w), citizen.Scale(h))
end

function PANEL:SetASize(w, h)
    self:Size(w, h)
end

function PANEL:SetAPos(x, y)
    self:Pos(x, y)
end

function PANEL:SetATall(h)
    self:SetSize(self:GetWide(), citizen.Scale(h))
end

function PANEL:SetAWide(w)
    self:SetSize(citizen.Scale(w), self:GetTall())
end

function PANEL:SmoothAppear(setAlpha, speed)
    if setAlpha then
        self:SetAlpha(0)
    end
    
    self:AlphaTo(255, speed or .2)
end

local sw, sh = ScrW(), ScrH()

function PANEL:RunAnimation(_x, _y)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0)
    self.Initing = true

    self:SetPos(sw * .5 - self:GetWide() * .5, sh)

    local x = _x or (sw * .5 - self:GetWide() * .5)
    local y = _y or (sh * .5 - self:GetTall() * .5)

    timer.Simple(0, function()
        self:MoveTo(x, y, 0.6, 0, 0.2, function()
            self.Initing = false
        end)
    end)
end

function PANEL:LerpColor(baseColor, hoverColor, speed)
    speed = speed or 5
    self._hoverLerp = self._hoverLerp or 0

    local delta = FrameTime() * speed
    if self:IsHovered() then
        self._hoverLerp = math.min(self._hoverLerp + delta, 1)
    else
        self._hoverLerp = math.max(self._hoverLerp - delta, 0)
    end

    local t = self._hoverLerp
    return Color(
        Lerp(t, baseColor.r, hoverColor.r),
        Lerp(t, baseColor.g, hoverColor.g),
        Lerp(t, baseColor.b, hoverColor.b),
        Lerp(t, baseColor.a, hoverColor.a)
    )
end

function PANEL:RemoveAnimation()
    self:MoveTo(sw * .5 - self:GetWide() * .5, sh, .6, 0, .3)

    if self.OnRemoveAnim then
        self.OnRemoveAnim(self)
    end
    
    self:AlphaTo(0, .3, 0, function()
        self:Remove()
    end)
end

function PANEL:SmoothRemove(speed)
    self:AlphaTo(0, speed or .2, 0, function()
        self:Remove()
    end)
end

local sw, sh = ScrW(), ScrH()
local blur = Material('pp/blurscreen')
function citizen.Blur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(blur)

    for i = 1, 5 do
        blur:SetFloat('$blur', (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, sw, sh)
    end
end
