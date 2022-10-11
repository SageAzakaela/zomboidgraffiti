--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////

local Table = {};

Table.size = function(p1)
    local count = 0;

    if type(p1) == "table" then
    
        for k in pairs(p1) do
            count = count + 1;
        end

        return count
    end

    return count;
end

Table.isEmpty = function(p1)
    if Table.size(p1) == 0 then
        return true;
    end

    return false;
end

return Table