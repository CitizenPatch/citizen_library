
function citizen.Distance(pos1, pos2)
    if not isvector(pos1) or not isvector(pos2) then
        return 
    end
    
    return pos1:Distance2DSqr(pos2)
end