function hook.AddAfterEvent(event, uid, func, afterEvent)
    local n = string.format('hook.AddAfter:: %q; %q', event, uid)
    
    hook.Add(afterEvent, n, function()
        hook.Remove(afterEvent, n)
        hook.Add(event, uid, func)
    end)
end
