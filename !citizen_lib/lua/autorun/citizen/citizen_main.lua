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