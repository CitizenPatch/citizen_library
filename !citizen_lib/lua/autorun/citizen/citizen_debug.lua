citizen.debug = {}

function citizen.debug.PerformanceTest(func, times)
    if not isfunction(func) then
        return citizen.Log('Isnt func...')
    end

    if not isnumber(times) or times <= 0 then
        return    
    end

    util.TimerCycle()

    for i = 1, times do
        func()
    end

    local time = util.TimerCycle()
    citizen.Log(string.format('Перфтест: %d раз - %d', times, time))

    return time
end
