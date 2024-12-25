local Collection = require("classes.data_structures.collection")
local dict = require("classes.data_structures.dict")
local list = require("classes.data_structures.list")
local set = require("classes.data_structures.set")
local stack = require("classes.data_structures.stack")
local queue = require("classes.data_structures.queue")
local deque = require("classes.data_structures.deque")
local ordered_dict = require("classes.data_structures.ordered_dict")
local priority_queue = require("classes.data_structures.priority_queue")



--- Returns the data structure class as specified in the class name variable
---@param class_name string
---@return Collection
local function get_data_structure(class_name)
    --- Returns the data structure class
    if class_name == "Dict" then
        return dict
    elseif class_name == "List" then
        return list
    elseif class_name == "Set" then
        return set
    elseif class_name == "Stack" then
        return stack
    elseif class_name == "Queue" then
        return queue
    elseif class_name == "Deque" then
        return deque
    elseif class_name == "OrderedDict" then
        return ordered_dict
    elseif class_name == "PriorityQueue" then
        return priority_queue
    else
        return list
    end
end

return get_data_structure
