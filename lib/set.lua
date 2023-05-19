--[[
    derived from documentation and reference implementation at:
    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/lastIndexOf
    Attributions and copyright licensing by Mozilla Contributors is licensed under CC-BY-SA 2.5
]]
--!strict
type Object = { [string]: any }

local Set = {}
Set.__index = Set
type Set = {
  new: (collection: string | Object) -> Set,
  add: (self: Set, item: any) -> Set,
  clear: (self: Set) -> (),
}

function Set.new(collection: string | Object): Set
  local internalMap = {}
  local internalArray

  if collection == nil then
    internalArray = {}
  else
    error("es7-lua doesn't currently support copy ctor from other collections")
  end

  return (
    setmetatable({
      __internalMap = internalMap,
      __internalArray = internalArray,
      size = #internalArray,
    }, Set) :: any
  ) :: Set
end

function Set:add(item)
  if self.__internalMap[item] ~= nil then
    return self
  end
  table.insert(self.__internalArray, item)
  self.__internalMap[item] = true
  return self
end

function Set:clear()
  table.clear(self.__internalArray)
  table.clear(self.__internalMap)
end

return Set
