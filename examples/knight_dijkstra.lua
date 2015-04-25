-- Calculates shortest path of Knight from (1, 1) to (x, y).
-- Prints matrix of shortest paths for all cells.
-- Knight can't leave the rectangle from (1, 1) to (x, y).

-- See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
-- See http://stackoverflow.com/questions/2339101

-- Usage:
-- $ lua knight_dijkstra.lua X Y

local binaryheap = require 'binaryheap'

local ROWS = tonumber(arg[2]) or 8
local COLS = tonumber(arg[1]) or 8

local unvisited = binaryheap.minUnique()

local function Cell(x, y)
  return x .. '_' .. y
end

local function Coordinates(cell)
  local x, y = cell:match('(%d+)_(%d+)')
  return x, y
end

local function neighbours(cell)
  local x, y = Coordinates(cell)
  local gen = coroutine.wrap(function()
    coroutine.yield(x - 1, y - 2)
    coroutine.yield(x - 1, y + 2)
    coroutine.yield(x + 1, y - 2)
    coroutine.yield(x + 1, y + 2)
    coroutine.yield(x - 2, y - 1)
    coroutine.yield(x - 2, y + 1)
    coroutine.yield(x + 2, y - 1)
    coroutine.yield(x + 2, y + 1)
  end)
  return coroutine.wrap(function()
    for x, y in gen do
      if 1 <= x and x <= COLS and
          1 <= y and y <= ROWS then
        coroutine.yield(Cell(x, y))
      end
    end
  end)
end

for y = 1, ROWS do
  for x = 1, COLS do
    local cell = Cell(x, y)
    unvisited:insert(math.huge, cell)
  end
end
unvisited:update('1_1', 0)

local final_distance = {}

while unvisited:peek() do
  local current_distance, current = unvisited:peek()
  assert(not final_distance[current])
  final_distance[current] = current_distance
  unvisited:remove(current)
  -- update neighbours
  local new_distance = current_distance + 1
  for neighbour in neighbours(current) do
    if unvisited.reverse[neighbour] then
      local pos = unvisited.reverse[neighbour]
      local distance = unvisited.value[pos]
      if distance > new_distance then
        unvisited:update(neighbour, new_distance)
      end
    end
  end
end

for y = 1, ROWS do
  local row = {}
  for x = 1, COLS do
    local cell = Cell(x, y)
    local distance = final_distance[cell]
    table.insert(row, distance)
  end
  print(table.concat(row, ' '))
end
