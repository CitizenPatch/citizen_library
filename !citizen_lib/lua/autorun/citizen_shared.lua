citizen = citizen or {}
citizen.version = 1.0

f = Format

function citizen.f(str, ...)
    local args = {...}
    local i = 1
    
    return (str:gsub('{%w+}', function()
        local val = args[i]
        i = i + 1
        return tostring(val)
    end))
end

-- ;)
setmetatable(hook, {
    __call = function(_, event, name, func)
        if not func then
            func = name
            name = citizen.f('Citizen>Hook>{s}', tostring(util.CRC(CurTime())))
        end
        
        return hook.Add(event, name, func)
    end
})

function citizen.rgb(r, g, b, a)
    r = (r / 255) ^ (1 / 2.2) * 255
    b = (b / 255) ^ (1 / 2.2) * 255
    g = (g / 255) ^ (1 / 2.2) * 255
    a = a or 255

    return Color(r, g, b, a)
end

function printf(fmt, ...)
    print(string.format(fmt, ...))
end

function citizen.RandomString(len)
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local str = ''

    for i = 1, len do
        local r = math.random(1, #chars)
        str = str .. chars:sub(r, r)
    end

    return str
end

function citizen.Log(...)
    local args = {...}

    local function toStringTable(tbl, indent)
        if not istable(tbl) then return tostring(tbl) end

        indent = indent or 0

        local result = '{\n'
        for k, v in next, tbl do
            local kStr = '[' .. tostring(k) .. ']'
            local vStr = istable(v) and toStringTable(v, indent + 2) or tostring(v)
            result = result .. string.rep(' ', indent + 2) .. kStr .. ' = ' .. vStr .. ',\n'
        end

        return result .. string.rep(' ', indent) .. '}'
    end

    local output = {}
    for _, v in ipairs(args) do
        table.insert(output, toStringTable(v))
    end

    MsgC(Color(255, 0, 132), table.concat(output, ' ') .. '\n')
end

local function LoadFile(fName, realm)
    local fPath = 'autorun/citizen/' .. fName .. '.lua'

    if file.Exists(fPath, 'LUA') then
        if realm == 'sv' then
            include(fPath)
            citizen.Log('Файл ' .. fName .. ' загружен на сервере.')
        elseif realm == 'cl' then
            if SERVER then
                AddCSLuaFile(fPath)
            else
                local ret = include(fPath)
                citizen.Log('Файл ' .. fName .. ' загружен на клиенте.')

                return ret
            end
        elseif realm == 'sh' then
            if SERVER then
                AddCSLuaFile(fPath)
            end

            include(fPath)
            citizen.Log('Файл ' .. fName .. ' загружен на сервере и клиенте.')
        else
            citizen.Log('Ошибка: Неверное значение realm! Используйте \'sv\', \'cl\' или \'sh\'.')
        end
    else
        citizen.Log('Ошибка: файл ' .. fPath .. ' не найден!')
    end
end

LoadFile('citizen_playerutils', 'sh') 
LoadFile('citizen_hook', 'sh') 
LoadFile('citizen_cmd', 'sh') 
LoadFile('citizen_other', 'sh') 
LoadFile('citizen_vgui', 'cl') 
LoadFile('citizen_main', 'cl') 
LoadFile('citizen_ui', 'cl') 
LoadFile('citizen_debug', 'sh') 
LoadFile('citizen_version', 'sv') 
LoadFile('sfs', 'sh') 
LoadFile('netstream', 'sh') 
LoadFile('nw', 'sh')

PLAYER = FindMetaTable('Player')
ENTITY = FindMetaTable('Entity')

if CLIENT then
    citizen.ScrW = ScrW()
    citizen.ScrH = ScrH()
    rndx = include('autorun/rndx.lua')
end

print('Meta for PLAYER and ENTITY was cached! (PLAYER & ENTITY TABLE)')