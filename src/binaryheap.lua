-------------------------------------------------------------------
-- [Binary heap](http://en.wikipedia.org/wiki/Binary_heap) implementation
-- 
-- [Original code](http://lua-users.org/lists/lua-l/2015-04/msg00137.html) 
-- by Oliver Kroth, with 
-- [extras](http://lua-users.org/lists/lua-l/2015-04/msg00133.html)
-- as proposed by Sean Conner.
-- 
-- The 'plain binary heap' is managed by positions. Which are hard to get once
-- an element is inserted. It can be anywhere in the list because it is re-sorted 
-- upon insertion/deletion of items.
--
-- A 'unique binary heap' is where the payload is unique and the payload itself
-- also stored (as key) in the heap with the position as value, as in;
--     `heap[payload] = [pos]`
--
-- Due to this setup the reverse search, based on `payload`, is now a
-- much faster operation because instead of traversing the list/heap, you can do;
--     `pos = heap[payload]`
--
-- This means that deleting elements from a 'unique binary heap' is faster than from a plain heap.
-- 
-- All management functions in the 'unique binary heap' take `payload` instead of `pos` as argument.
-- Note that the value of the payload must be unique and should not collide with;
--
--  - numerical indexes
--  - method names
--
-- As these are also stored in the same table.


local M = {}
local floor = math.floor

--================================================================
-- basic heap sorting algorithm
--================================================================

--- Creates a new binary heap. 
-- This is the core of all heaps, the others
-- are built upon these sorting functions.
-- @param swap (function) `swap(list, idx1, idx2)` swaps values at `idx1` and `idx2` in table `list`.
-- @param lt (function) in `lt(a, b)` returns `true` when `a < b` (for a min-heap)
-- @param lte (function) in `lte(a,b)` returns `true` when `a <= b` (for a min-heap)
-- @return table with two methods; `tbl:bubbleUp(pos)` and `tbl:sinkDown(pos)` that implement the sorting algorithm
M.binaryHeap = function(swap, lt, lte)
  
  local function bubbleUp(heap, pos)
    while pos>1 do
      local parent = floor(pos/2)
      if lte(heap[parent].value, heap[pos].value) then break end
      swap(heap, parent, pos)
      pos = parent
    end
  end

  local function sinkDown(heap, pos)
    local last = #heap
    while true do
      local min = pos
      local child = 2*pos

      for c=child, child+1 do
        if c <= last and lt(heap[c].value, heap[min].value) then min = c end
      end
      
      if min == pos then break end
    
      swap(heap, pos, min)
      pos = min
    end
  end
  
  return { bubbleUp = bubbleUp, sinkDown = sinkDown }
end

--================================================================
-- plain heap management functions
--================================================================

local update
--- Updates the value of an element in the heap.
-- @name heap:update
-- @param pos the position which value to update
-- @param newValue the new value to use for this payload
update = function(self, pos, newValue)
  self[pos].value = newValue
  if pos>1 then self:bubbleUp(pos) end
  if pos<#self then self:sinkDown(pos) end
end

local remove
--- Removes an element from the heap.
-- @name heap:remove
-- @param pos the position to remove
-- @return payload, value or nil + error if an illegal `pos` value was provided
remove = function(self, pos)
	local last = #self
	if pos<1 or pos>last then return nil, "illegal position" end
	
	local node = self[pos]
	
	if pos<last then
		self[pos] = self[last]
		self:bubbleUp(pos)
		self:sinkDown(pos)
	end
	
	self[last] = nil
	return node.payload, node.value
end

local insert
--- Inserts an element in the heap.
-- @name heap:insert
-- @param value the value used for sorting this element
-- @param payload the payload attached to this element
insert = function(self, value, payload)
	local pos = #self+1
	self[pos] =  {value=value, payload=payload}
	self:bubbleUp(pos)
end

local pop
--- Removes the top of the heap and returns it.
-- @name heap:pop
-- When used with timers, `pop` will return the payload that is due.
-- 
-- Note: this function returns `payload` as the first result to prevent extra locals
-- when retrieving the `payload`.
-- @return payload + value at the top, or `nil` if there is none
pop = function(self)
  return self:remove(1)   -- note: method call to also handle unique heap
end

local peek
--- Returns the element at the top of the heap, without removing it.
-- When used with timers, `peek` will tell when the next timer is due.
-- @name heap:peek
-- @return value + payload at the top, or `nil` if there is none
-- @usage -- simple timer based heap example
-- while true do
--   sleep(heap:peek() - gettime())  -- assume LuaSocket gettime function
--   coroutine.resume((heap:pop()))  -- assumes payload to be a coroutine, double parens to drop extra return value 
-- end
peek = function(self)
  local node = (self or {})[1] or {}
  return node.value, node.payload
end

--================================================================
-- plain heap creation
--================================================================

--- Creates a new min-heap. A min-heap is where the smallest value is at the top.
-- @return the new heap
M.minHeap = function()
  local swap = function(list, a, b) list[a], list[b] = list[b], list[a] end
  local lt = function(a,b) return (a<b) end
  local lte = function(a,b) return (a<=b) end
  local h = M.binaryHeap(swap, lt, lte)
  h.peek = peek
  h.pop = pop
  h.remove = remove
  h.insert = insert
  h.update = update
  return h
end

--- Creates a new max-heap. A max-heap is where the largest value is at the top.
-- @return the new heap
M.maxHeap = function()
  local swap = function(list, a, b) list[a], list[b] = list[b], list[a] end
  local gt = function(a,b) return (a>b) end
  local gte = function(a,b) return (a>=b) end
  local h = M.binaryHeap(swap, gt, gte)
  h.peek = peek
  h.pop = pop
  h.remove = remove
  h.insert = insert
  h.update = update
  return h
end

--================================================================
-- unique heap management functions
--================================================================

--- Updates the value of an element in the heap.
-- @param payload the payoad whose value to update
-- @param newValue the new value to use for this payload
local function updateU(self, payload, newValue)
  return update(self, self[payload], newValue)
end

--- Inserts an element in the heap.
-- @param value the value used for sorting this element
-- @param payload the payload attached to this element
local function insertU(self, value, payload)
  self[payload] = #self+1
  return insert(self, value, payload)
end

--- Removes an element from the heap.
-- @param payload the payload to remove
-- @return payload, value or nil + error if an illegal `pos` value was provided
local function removeU(self, payload)
  local pos = self[payload]
  self[payload] = nil
  return remove(self, pos)
end

--================================================================
-- unique heap creation
--================================================================

--- Creates a new min-heap with unique payloads. A min-heap is where the smallest value is at the top.
-- @return the new heap
M.minUnique = function()
  local swap = function(list, a, b) 
    list[list[a].payload], list[a], list[list[b].payload], list[b] = b, list[b], a, list[a]
  end
  local lt = function(a,b) return (a<b) end
  local lte = function(a,b) return (a<=b) end
  local h = M.binaryHeap(swap, lt, lte)
  h.peek = peek
  h.pop = pop
  h.remove = removeU
  h.insert = insertU
  h.update = updateU
  return h
end

--- Creates a new max-heap with unique payloads. A max-heap is where the largest value is at the top.
-- @return the new heap
M.maxUnique = function()
  local swap = function(list, a, b) 
    list[a.payload], list[a], list[b.payload], list[b] = b, list[b], a, list[a]
  end
  local gt = function(a,b) return (a>b) end
  local gte = function(a,b) return (a>=b) end
  local h = M.binaryHeap(swap, gt, gte)
  h.peek = peek
  h.pop = pop
  h.remove = removeU
  h.insert = insertU
  h.update = updateU
  return h
end

return M

