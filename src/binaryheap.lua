-------------------------------------------------------------------
-- [Binary heap](http://en.wikipedia.org/wiki/Binary_heap) implementation
--
-- The 'plain binary heap' is managed by positions. Which are hard to get once
-- an element is inserted. It can be anywhere in the list because it is re-sorted
-- upon insertion/deletion of items.
--
-- A 'unique binary heap' is where the payload is unique and the payload itself
-- also stored (as key) in the heap with the position as value, as in;
--     `heap.reverse[payload] = [pos]`
--
-- Due to this setup the reverse search, based on `payload`, is now a
-- much faster operation because instead of traversing the list/heap,
-- you can do;
--     `pos = heap.reverse[payload]`
--
-- This means that deleting elements from a 'unique binary heap' is
-- faster than from a plain heap.
--
-- All management functions in the 'unique binary heap' take `payload`
-- instead of `pos` as argument.
-- Note that the value of the payload must be unique!

local M = {}
local floor = math.floor

--================================================================
-- basic heap sorting algorithm
--================================================================

--- Creates a new binary heap.
-- This is the core of all heaps, the others
-- are built upon these sorting functions.
-- @param swap (function) `swap(heap, idx1, idx2)` swaps values at
-- `idx1` and `idx2` in the heaps `heap.value` and `heap.payload` lists (see
-- return value below).
-- @param erase (function) `swap(heap, position)` raw removal
-- @param lt (function) in `lt(a, b)` returns `true` when `a < b`
--  (for a min-heap)
-- @return table with two methods; `heap:bubbleUp(pos)` and `heap:sinkDown(pos)`
-- that implement the sorting algorithm and two fields; `heap.value` and
-- `heap.payload` being lists, holding the values and payloads respectively.
M.binaryHeap = function(swap, erase, lt)

  local heap = {
      value = {},  -- list containing values
      erase = erase,
      swap = swap,
      lt = lt,
    }

  function heap:bubbleUp(pos)
    while pos>1 do
      local parent = floor(pos/2)
      if not lt(self.value[pos], self.value[parent]) then
          break
      end
      swap(self, parent, pos)
      pos = parent
    end
  end

  function heap:sinkDown(pos)
    local last = #self.value
    while true do
      local min = pos
      local child = 2*pos

      for c=child, child+1 do
        if c <= last and lt(self.value[c], self.value[min]) then min = c end
      end

      if min == pos then break end

      swap(self, pos, min)
      pos = min
    end
  end

  function heap:check()
    for pos, value in ipairs(self.value) do
      local payload = self.payload[pos]
      assert(self.reverse[payload] == pos, pos)
      if pos ~= 1 then
        local parent = math.floor(pos / 2)
        assert(not lt(value, self.value[parent]), pos)
      end
    end
  end

  return heap
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
  self.value[pos] = newValue
  if pos>1 then self:bubbleUp(pos) end
  if pos<#self.value then self:sinkDown(pos) end
end

local remove
--- Removes an element from the heap.
-- @name heap:remove
-- @param pos the position to remove
-- @return payload, value or nil + error if an illegal `pos` value was provided
remove = function(self, pos)
  local last = #self.value
  if pos<1 or pos>last then
    return nil, "illegal position"
  end
  local v = self.value[pos]
  if pos<last then
    self:swap(pos, last)
    self:erase(last)
    self:bubbleUp(pos)
    self:sinkDown(pos)
  else
    self:erase(last)
  end
  local payload = nil
  return payload, v
end

local insert
--- Inserts an element in the heap.
-- @name heap:insert
-- @param value the value used for sorting this element
insert = function(self, value)
  local pos = #self.value+1
  self.value[pos] = value
  self:bubbleUp(pos)
end

local pop
--- Removes the top of the heap and returns it.
-- @name heap:pop
-- When used with timers, `pop` will return the payload that is due.
--
-- Note: this function returns `payload` as the first result to prevent
-- extra locals when retrieving the `payload`.
-- @return payload + value at the top, or `nil` if there is none
pop = function(self)
  if self.value[1] then
    return remove(self, 1)
  end
end

local peek
--- Returns the element at the top of the heap, without removing it.
-- @name heap:peek
-- @return value at the top, or `nil` if there is none
peek = function(self)
  return self.value[1]
end

local function swap(heap, a, b)
  heap.value[a], heap.value[b] = heap.value[b], heap.value[a]
end

local function erase(heap, pos)
  heap.value[pos] = nil
end

--================================================================
-- plain heap creation
--================================================================

--- Creates a new min-heap, where the smallest value is at the top.
-- @param lt (optional) comparison function (less-than), see `binaryHeap`.
-- @return the new heap
M.minHeap = function(lt)
  if not lt then
    lt = function(a,b) return (a<b) end
  end
  local h = M.binaryHeap(swap, erase, lt)
  h.peek = peek
  h.pop = pop
  h.remove = remove
  h.insert = insert
  h.update = update
  return h
end

--- Creates a new max-heap, where the largest value is at the top.
-- @param gt (optional) comparison function (greater-than), see `binaryHeap`.
-- @return the new heap
M.maxHeap = function(gt)
  if not gt then
    gt = function(a,b) return (a>b) end
  end
  local h = M.binaryHeap(swap, erase, gt)
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

local updateU
--- Updates the value of an element in the heap.
-- @name unique:update
-- @param payload the payoad whose value to update
-- @param newValue the new value to use for this payload
function updateU(self, payload, newValue)
  return update(self, self.reverse[payload], newValue)
end

local insertU
--- Inserts an element in the heap.
-- @name unique:insert
-- @param value the value used for sorting this element
-- @param payload the payload attached to this element
function insertU(self, value, payload)
  local pos = #self.value + 1
  self.reverse[payload] = pos
  self.payload[pos] = payload
  return insert(self, value, payload)
end

local removeU
--- Removes an element from the heap.
-- @name unique:remove
-- @param payload the payload to remove
-- @return payload, value or nil + error if an illegal `pos` value was provided
function removeU(self, payload)
  local pos = assert(self.reverse[payload])
  local _, value = remove(self, pos)
  return payload, value
end

local popU
--- Removes the top of the heap and returns it.
-- @name unique:pop
-- When used with timers, `pop` will return the payload that is due.
--
-- Note: this function returns `payload` as the first result to prevent
-- extra locals when retrieving the `payload`.
-- @return payload + value at the top, or `nil` if there is none
function popU(self)
  if self.value[1] then
    local payload = self.payload[1]
    local _, value = remove(self, 1)
    return payload, value
  end
end

local peekU
--- Returns the element at the top of the heap, without removing it.
-- When used with timers, `peek` will tell when the next timer is due.
-- @name unique:peek
-- @return value, payload at the top, or `nil` if there is none
-- @usage -- simple timer based heap example
-- while true do
--   sleep(heap:peek() - gettime())  -- assume LuaSocket gettime function
--   coroutine.resume((heap:pop()))  -- assumes payload to be a coroutine,
--                                   -- double parens to drop extra return value
-- end
peekU = function(self)
  return self.value[1], self.payload[1]
end

local function swapU(heap, a, b)
  local pla, plb = heap.payload[a], heap.payload[b]
  heap.reverse[pla], heap.reverse[plb] = b, a
  heap.payload[a], heap.payload[b] = plb, pla
  swap(heap, a, b)
end

local function eraseU(heap, pos)
  local payload = heap.payload[pos]
  heap.reverse[payload] = nil
  heap.payload[pos] = nil
  erase(heap, pos)
end

--================================================================
-- unique heap creation
--================================================================

--- Creates a new min-heap with unique payloads.
-- A min-heap is where the smallest value is at the top.
--
-- *NOTE*: All management functions in the 'unique binary heap'
-- take `payload` instead of `pos` as argument.
-- @param lt (optional) comparison function (less-than), see `binaryHeap`.
-- @return the new heap
M.minUnique = function(lt)
  if not lt then
    lt = function(a,b) return (a<b) end
  end
  local h = M.binaryHeap(swapU, eraseU, lt)
  h.payload = {}  -- list contains payloads
  h.reverse = {}  -- reverse of the payload list
  h.peek = peekU
  h.pop = popU
  h.remove = removeU
  h.insert = insertU
  h.update = updateU
  return h
end

--- Creates a new max-heap with unique payloads.
-- A max-heap is where the largest value is at the top.
--
-- *NOTE*: All management functions in the 'unique binary heap'
-- take `payload` instead of `pos` as argument.
-- @param gt (optional) comparison function (greater-than), see `binaryHeap`.
-- @return the new heap
M.maxUnique = function(gt)
  if not gt then
    gt = function(a,b) return (a>b) end
  end
  local h = M.binaryHeap(swapU, eraseU, gt)
  h.payload = {}  -- list contains payloads
  h.reverse = {}  -- reverse of the payload list
  h.peek = peekU
  h.pop = popU
  h.remove = removeU
  h.insert = insertU
  h.update = updateU
  return h
end

return M
