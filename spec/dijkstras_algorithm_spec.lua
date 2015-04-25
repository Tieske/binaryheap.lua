describe("dijkstras algorithm with binaryheap", function()
  -- See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm

  it("calculates knight's shortest path", function()
    -- See http://stackoverflow.com/questions/2339101

    local binaryheap = require 'binaryheap'

    local ROWS = 8
    local COLS = 8

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
          local distance = unvisited.values[pos]
          if distance > new_distance then
            unvisited:update(neighbour, new_distance)
          end
        end
      end
    end

    local rows = {}
    for y = 1, ROWS do
      local row = {}
      for x = 1, COLS do
        local cell = Cell(x, y)
        local distance = final_distance[cell]
        table.insert(row, distance)
      end
      table.insert(rows, table.concat(row, ' '))
    end

    assert.equal([[
0 3 2 3 2 3 4 5
3 4 1 2 3 4 3 4
2 1 4 3 2 3 4 5
3 2 3 2 3 4 3 4
2 3 2 3 4 3 4 5
3 4 3 4 3 4 5 4
4 3 4 3 4 5 4 5
5 4 5 4 5 4 5 6]],
    table.concat(rows, '\n'))
  end)
end)
