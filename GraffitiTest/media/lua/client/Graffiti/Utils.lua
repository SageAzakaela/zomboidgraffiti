--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////

local Math = require "Graffiti/Utils/Math";
local Table = require "Graffiti/Utils/Table";
local Utils = {};

Utils.Math = Math;
Utils.Table = Table;


Utils.findItems = function(p1, p2)
    local inventory = p1:getInventory();
    local items = inventory:getItems();
    local newItems = {};
    
    for i = 0, items:size() - 1 do
        if type(p2) == "string" and p2 == items:get(i):getFullType() then
            table.insert(newItems, items:get(i))
        end

        if type(p2) == "table" then
            for k, v in pairs(p2) do
                if v == items:get(i):getFullType() then
                    table.insert(newItems, items:get(i))
                end
            end
        end
    end

    if not Table.isEmpty(newItems) then
        return newItems
    end

    return nil
end

return Utils