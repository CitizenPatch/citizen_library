local url = 'https://raw.githubusercontent.com/CitizenPatch/citizen_library/refs/heads/main/version.txt'

local function CheckVersion()
    http.Fetch(url, function(body, size, headers, code)
        local latest = tonumber(body)

        if latest > citizen.version then
            citizen.Log(citizen.f('[CLib] Доступна новая версия: {d} ({s}) (установлена: {d})',
                latest,
                'https://github.com/CitizenPatch/citizen_library',
                citizen.version
            ))
        elseif latest == citizen.version then
            citizen.Log(citizen.f('[CLib] Установлена актуальная версия: {d}', citizen.version))
        else
            citizen.Log('[CLib] Ваша версия новее версии на github :\\')
        end
    end, function(err)
        citizen.Log('[CLib] Ошибка при проверке версии: ' .. err)
    end)
end

hook('Initialize', 'Citizen>CheckVersion', function()
    for i = 1, 3 do
        CheckVersion()
    end
end)
