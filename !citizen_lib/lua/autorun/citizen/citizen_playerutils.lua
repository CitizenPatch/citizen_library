local _PLY = FindMetaTable('Player')

function citizen.FindPlayer(uid)
    if isentity(uid) and uid:IsPlayer() then
        return uid
    end

    for _, ply in player.Iterator() do
        if string.find(string.lower(ply:Nick()), string.lower(uid)) then
            return ply
        elseif ply:SteamID() == uid then 
            return ply
        elseif ply:SteamID64() == uid then
            return ply
        end
    end

    return nil
end

function _PLY:ID()
    return self:SteamID()
end

if CLIENT then
    citizen.OldLocalPlayer = citizen.OldLocalPlayer or LocalPlayer
    citizen.LocalPlayer = citizen.LocalPlayer or LocalPlayer()

    hook('InitPostEntity', 'citizen>ParseLocalPlayer', function()
        local ply = LocalPlayer()
        citizen.LocalPlayer = ply
        
        function LocalPlayer()
            return ply
        end
    end)
end
