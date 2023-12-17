-- create.lua
-- this is similar to the Roact.createElement() method.

local function create(class: string, properties: {[string]: any}?, children: {[string]: Instance}?, parent: Instance?)
    local object = Instance.new(class)
    if properties then
        for k, v in properties do
            object[k] = v
        end
    end

    -- do not parent the object until it is finished
    object.Parent = nil 

    if children then
        for n, inst in children do
            inst.Name = n
            inst.Parent = object
        end
    end

    -- all object creations are done, now parent it to the desired location
    object.Parent = parent

    return object
end

return create