--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////

local Math = {};

function Math.vector2(x, y)

    return {x = x, y = y};
end

function Math.vector3(x, y, z)

    return {x = x, y = y, z = z};
end

function Math.vdist(vector1, vector2)

    if type(vector1) == "table" and type(vector2) == "table" then
        if vector1.z and vector2.z then

            return math.sqrt(((vector1.x - vector2.x)^2) + ((vector1.y - vector2.y)^2) + ((vector1.z - vector2.z)^2));
        else

            return math.sqrt(((vector1.x - vector2.x)^2) + ((vector1.y - vector2.y)^2));
        end
    end

    return nil
end


return Math