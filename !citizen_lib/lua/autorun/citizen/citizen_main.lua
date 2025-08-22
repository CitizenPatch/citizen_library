local base_h = ScrH() / 1080
local ft = FrameTime
local cache_h = {}
local cache_mat = {}
local _oldColor = Color
local _colorCache = {}

function Color(r, g, b, a, lerp)
    if lerp then
        return _oldColor(r, g, b, a)
    end

    local key = citizen.f('{d}_{d}_{d}_{d}', r, g, b, a or 255)
    local cached = _colorCache[key]

    if cached then 
        return cached
    end

    local col = _oldColor(r, g, b, a)
    
    _colorCache[key] = col
    return col
end

function citizen.AnimateText(base, interval)
    local dots = math.floor((CurTime() * 2 / interval) % 4)
    
    return base .. string.rep('.', dots)
end

function citizen.LerpColor(col1, col2)
    return col1:Lerp(col2, ft() * 6)
end

local cur = 0
function citizen.Vignette(percent)
    percent = math.Clamp(percent or 0, 0, 1)
    
    local max = 90
    local t = percent * max

    cur = citizen.Lerp(cur, t)

    if cur < 1 then
        return
    end

    local w, h = citizen.ScrW, citizen.ScrH
    local cx, cy = w * .5, h * .5 

    rndx.DrawCircleOutlined(cx, cy, 1700, Color(0, 0, 0, cur), 400, 0)
end

local cachedMats = {}
function citizen.GetMaterial(shortcut)
    local image = cachedMats[shortcut]

    if !shortcut or !image then
        return Material('icon16/user.png')        
    end
    
    return image
end

function citizen.AddMaterial(shortcut, path, params)
    cachedMats[shortcut] = Material(path, params)
end

function citizen.Lerp(from, to, speed)
    if not speed then
        speed = 4
    end

    return Lerp(ft() * speed, from, to)
end

function citizen.DivColor(col, s)
    local r, g, b, a = col.a, col.b, col.g, col.a or 255
    return Color(r / s, g / s, b / s, a / s)
end

function citizen.PaintColor(val, clamp)
    return ColorAlpha(val, surface.GetAlphaMultiplier() * (clamp or 255))
end

function gui.HideGameUI()
    pcall(RunConsoleCommand, 'gamemenucommand', 'resumegame')
end

function citizen.CreateFont(name, family, size, antialias)
    local f = surface.CreateFont(name, {
        font = family,
        size = citizen.Scale(size),
        extended = true,
        antialias = antialias or true
    })

    -- citizen.Log(string.format('Registred font: name ^ %s ^; family ^ %s ^; size ^ %d ^; antialias ^ %s ^', name, family, size, tostring(antialias or false)))

    return f
end

function citizen.SmoothMaterial(material, params)
    if cache_mat[material] then 
        return cache_mat[material] 
    end
    
    local mat = Material(material, params or '')
    cache_mat[material] = mat

    return mat
end

local sw, sh = ScrW(), ScrH()
local mat_blur = Material('pp/blurscreen')

function citizen.ScreenBlur(x, y, w, h, n)
    if not n then n = 3 end
    surface.SetDrawColor(color_white)
    surface.SetMaterial(mat_blur)

    for i = 1, n do
        mat_blur:SetFloat('$blur', i)
        mat_blur:Recompute()
        render.UpdateScreenEffectTexture()
        render.SetScissorRect(x, y, x + w, y + h, true)
        surface.DrawTexturedRect(0, 0, sw, sh)
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

function citizen.DrawArc(x, y, ang, p, rad, color, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {x = x, y = y})

	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)
		table.insert(circle, {x = x + math.sin(a) * rad, y = y + math.cos(a) * rad})
	end

	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

function citizen.DrawMask(drawMask, draw)
    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)

    render.SetStencilFailOperation(STENCIL_REPLACE)
    render.SetStencilPassOperation( STENCIL_REPLACE)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilReferenceValue(1)

    drawMask()

    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilReferenceValue(1)

    draw()

    render.SetStencilEnable(false)
    render.ClearStencil()
end

function citizen.Scale(px)
    if cache_h[px] then
        return cache_h[px]
    else
        local result = math.Round(px * base_h)
        cache_h[px] = result
        return result
    end
end

hook('OnScreenSizeChanged', 'rp.RefreshScreenSize', function()
    base_h = ScrH() / 1080
    cache_h = {}
end)

-- ty to sincopa <3
local cachedText = setmetatable({}, {
    __mode = 'v'
})

local cachedTextProc = setmetatable({}, {
    __mode = 'v'
})

local function colorToString(color)
    return string.format('%d,%d,%d,%d', color.r or 255, color.g or 255, color.b or 255, color.a or 255)
end

local function segments(segments)
    local result = ''

    for _, segment in ipairs(segments) do
        local text = segment.text or ''
        if segment.font then text = string.format('<font=%s>%s</font>', segment.font, text) end
        if segment.color then text = string.format('<color=%s>%s</color>', colorToString(segment.color), text) end
        result = result .. text
    end

    return result
end

function draw.markupText(options)
    local text
    if type(options.text) == 'table' then
        text = cachedTextProc[options.text]
        if not text then
            text = segments(options.text)
            cachedTextProc[options.text] = text
        end
    else
        text = options.text or ''
        if options.font then text = string.format('<font=%s>%s</font>', options.font, text) end
        if options.color then text = string.format('<color=%s>%s</color>', colorToString(options.color), text) end
    end

    local parsed = cachedText[text]
    if not parsed then
        parsed = markup.Parse(text)
        cachedText[text] = parsed
    end

    parsed:Draw(options.x or 0, options.y or 0, options.alignX or TEXT_ALIGN_LEFT, options.alignY or TEXT_ALIGN_TOP,
        options.alpha or 255)
end

citizen.AddMaterial('vignette', 'citizen_materials/main/vignette.png')

local vignette = {
    Alpha = 0,
    Target = 0,
    Material = citizen.GetMaterial('vignette')
}

function citizen.Vignette(boolean)
    vignette.Target = boolean and 1 or 0
end

hook('HUDPaintBackground', 'citizen>Vignette', function()
    vignette.Alpha = citizen.Lerp(vignette.Alpha, vignette.Target)

    if vignette.Alpha <= 0.02 then
        return
    end

    rndx.DrawMaterial(0, 0, 0, citizen.ScrW, citizen.ScrH, ColorAlpha(color_black, vignette.Alpha * 255), vignette.Material)
end)