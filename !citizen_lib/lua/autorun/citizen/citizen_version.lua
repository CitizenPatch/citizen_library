local url = 'https://raw.githubusercontent.com/CitizenPatch/citizen_library/refs/heads/main/version.txt'

local function CheckVersion()
    http.Fetch(url, function(body, size, headers, code)
        local latest = tonumber(body)

        if latest then
            if latest > citizen.version then
                return citizen.f('[CLib] Доступна новая версия: {d} ({s}) (установлена: {d})', latest, 'https://github.com/CitizenPatch/citizen_library', citizen.version)
            elseif latest == citizen.version then
                return citizen.f('[CLib] Установлена актуальная версия: {d}', citizen.version)
            else
                return '[CLib] Ваша версия новее версии на github :\\'
            end
        end
    end)
end

hook('Initialize', 'Citizen>CheckVersion', function()
    for i = 1, 3 do
        citizen.Log(CheckVersion())
    end
end)