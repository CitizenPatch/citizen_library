citizen.cmd = {}
citizen.cmd.Storage = {}
citizen.cmd.Cooldowns = {}
local cmdMeta = {}
local cmd = concommand.Add
cmdMeta.__index = cmdMeta

if SERVER then
    util.AddNetworkString('citizen.SyncCmd')

    function cmdMeta:Send()
        citizen.Log('Sending CMD: ' .. self.name)
        net.Start('citizen.SyncCmd')
        net.WriteTable({name = self.name})
        net.Broadcast()
    end
else
    net.Receive('citizen.SyncCmd', function()
        local u = net.ReadTable()
        citizen.cmd.New(u.name)
    end)
end

local function getArgs(func)
    if not func or not isfunction(func) then
        return 0
    end

    local info = debug.getinfo(func, 'u')
    return info and info.nparams - 1 or 0
end

function citizen.cmd.New(name, func, cooldown, argsLang)
    local obj = {
        func = func,
        rawName = name,
        argC = getArgs(func),
        cooldown = cooldown or 0,
        argsLang = argsLang or {},
        access = function() return true end,
        noPrefix = true
    }

    setmetatable(obj, cmdMeta)

    obj.name = name
    citizen.cmd.Storage[name] = obj

    cmd(name, function(ply, _, args)
        local uid = ply:UID()

        if obj.cooldown > 0 then
            local last = citizen.cmd.Cooldowns[uid] and citizen.cmd.Cooldowns[uid][name] or 0
            if CurTime() - last < obj.cooldown then
                return
            end
        end

        if #args < obj.argC then
            local missing = {}
            for i = #args + 1, obj.argC do
                table.insert(missing, obj.argsLang[i] or "аргумент " .. i)
            end

            ply:ChatPrint('Ошибка: недостаточно аргументов. Требуется: ' .. table.concat(missing, ", "))
            return
        end

        if not obj.access(ply) then
            return
        end

        if func then func(ply, unpack(args)) end

        if obj.cooldown > 0 then
            citizen.cmd.Cooldowns[uid] = citizen.cmd.Cooldowns[uid] or {}
            citizen.cmd.Cooldowns[uid][name] = CurTime()
        end
    end)

    return obj
end

function cmdMeta:AddArg(arg)
    if istable(arg) then
        for _, v in ipairs(arg) do
            table.insert(self.argsLang, v)
        end
    else
        table.insert(self.argsLang, arg)
    end

    self.argC = #self.argsLang
    return self
end

function cmdMeta:SetAccess(func)
    self.access = func
    return self
end

function cmdMeta:SetCooldown(time)
    self.cooldown = time
    return self
end

function cmdMeta:SetPrefix(bool)
    self.noPrefix = bool
    return self
end

function cmdMeta:AddAlias(new)
    citizen.cmd.Storage[new] = {
        func = self.func,
        name = new,
        argC = self.argC,
        cooldown = self.cooldown,
        argsLang = self.argsLang,
        noPrefix = self.noPrefix
    }

    cmd(new, function(ply, _, args)
        local uid = ply:UID()

        if self.cooldown > 0 then
            local last = citizen.cmd.Cooldowns[uid] and citizen.cmd.Cooldowns[uid][new] or 0
            if CurTime() - last < self.cooldown then
                ply:ChatPrint('Ошибка: подождите ' .. math.ceil(self.cooldown - (CurTime() - last)) .. ' секунд(ы) перед повторным использованием команды.')
                return
            end
        end

        if #args < self.argC then
            ply:ChatPrint('Ошибка: недостаточно аргументов. Требуется минимум ' .. self.argC .. ' аргумента(ов).')
            return
        end

        if self.func then self.func(ply, unpack(args)) end

        if self.cooldown > 0 then
            citizen.cmd.Cooldowns[uid] = citizen.cmd.Cooldowns[uid] or {}
            citizen.cmd.Cooldowns[uid][new] = CurTime()
        end
    end)

    return citizen.cmd.Storage[new]
end
