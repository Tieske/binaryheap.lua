
local bh = require('binaryheap')

local data = {
  { value = 98, payload = "pos08" }, -- 1
  { value = 28, payload = "pos05" }, -- 2
  { value = 36, payload = "pos06" }, -- 3
  { value = 48, payload = "pos09" }, -- 4
  { value = 68, payload = "pos10" }, -- 5
  { value = 58, payload = "pos13" }, -- 6
  { value = 80, payload = "pos15" }, -- 7
  { value = 46, payload = "pos04" }, -- 8
  { value = 19, payload = "pos03" }, -- 9
  { value = 66, payload = "pos11" }, -- 10
  { value = 22, payload = "pos02" }, -- 11
  { value = 60, payload = "pos12" }, -- 12
  { value = 15, payload = "pos01" }, -- 13
  { value = 83, payload = "pos14" }, -- 14
  { value = 59, payload = "pos07" }, -- 15
}

local sort = function(t)
  table.sort(t, function(a,b) return (a.value < b.value) end)
  return t
end

local function check(heap)
  for pos = 2, #heap.values do
    local parent = math.floor(pos / 2)
    assert(not heap.lt(heap.values[pos], heap.values[parent]))
  end
  if heap.payloads then
    for pos, value in ipairs(heap.values) do
      local payload = heap.payloads[pos]
      assert(heap.reverse[payload] == pos)
    end
  end
end

local function newheap()
  -- create a heap with data
  local heap = bh.minUnique()
  for _, node in ipairs(data) do
    heap:insert(node.value,node.payload)
    check(heap)
  end

  -- create a sorted list with data, sorted by 'value'
  local sorted = {}
  for k,v in pairs(data) do sorted[k] = v end
  sort(sorted)
  -- create a reverse list of the sorted table; returns sorted-index, based on 'value'
  local sreverse = {}
  for i,v in ipairs(sorted) do
    sreverse[v.value] = i
  end
  return heap, sorted, sreverse
end

local function testheap(heap, sorted)
  while sorted[1] do
    local value1, payload1 = heap:pop()
    local value2, payload2 = sorted[1].value, sorted[1].payload
    table.remove(sorted, 1)
    assert.are.equal(payload1, payload2)
    assert.are.equal(value1, value2)
  end
end

describe("Testing minUnique heap", function()

  it("tests order of insertion", function()
    local h = newheap()
    assert.are.equal(h.payloads[1], data[13].payload)
    assert.are.equal(h.payloads[2], data[11].payload)
    assert.are.equal(h.payloads[3], data[9].payload)
    assert.are.equal(h.payloads[4], data[8].payload)
    assert.are.equal(h.payloads[5], data[2].payload)
    assert.are.equal(h.payloads[6], data[3].payload)
    assert.are.equal(h.payloads[7], data[15].payload)
    assert.are.equal(h.payloads[8], data[1].payload)
    assert.are.equal(h.payloads[9], data[4].payload)
    assert.are.equal(h.payloads[10], data[5].payload)
    assert.are.equal(h.payloads[11], data[10].payload)
    assert.are.equal(h.payloads[12], data[12].payload)
    assert.are.equal(h.payloads[13], data[6].payload)
    assert.are.equal(h.payloads[14], data[14].payload)
    assert.are.equal(h.payloads[15], data[7].payload)
  end)

  it("Tests order of popping", function()
    testheap(newheap())
  end)

  it("Tests peek()", function()
    local heap, sorted, sreverse = newheap()
    local value, payload = heap:peek()
    -- correct values?
    assert.are.equal(value, sorted[1].value)
    assert.are.equal(payload, sorted[1].payload)
    -- are they still on the heap?
    assert.are.equal(value, heap.values[1])
    assert.are.equal(payload, heap.payloads[1])
  end)

  describe("Testing removing elements", function()
    it("Tests removing a middle item", function()
      local heap, sorted, sreverse = newheap()
      local idx = 4
      local value = sorted[idx].value
      local payload = sorted[idx].payload
      local v, pl = heap:remove(payload)
      check(heap)
      -- did we get the right ones?
      assert.are.equal(value, v)
      assert.are.equal(payload, pl)
      assert.is.Nil(heap[payload])
      -- remove from test data and compare
      table.remove(sorted, idx)
      testheap(heap, sorted)
    end)

    it("Tests removing the last item (of the array)", function()
      local heap, sorted, sreverse = newheap()
      local idx = #heap.values
      local value = sorted[idx].value
      local payload = sorted[idx].payload
      local v, pl = heap:remove(payload)
      check(heap)
      -- did we get the right ones?
      assert.are.equal(value, v)
      assert.are.equal(payload, pl)
      assert.is.Nil(heap.reverse[payload])
      -- remove from test data and compare
      table.remove(sorted, idx)
      testheap(heap, sorted)
    end)
  end)

  describe("Testing inserting elements", function()
    it("Tests inserting a top item", function()
      local heap, sorted, sreverse = newheap()
      local nvalue = sorted[1].value - 10
      local npayload = {}
      table.insert(sorted, 1, {})
      sorted[1].value = nvalue
      sorted[1].payload = npayload
      heap:insert(nvalue, npayload)
      check(heap)
      testheap(heap, sorted)
    end)

    it("Tests inserting a middle item", function()
      local heap, sorted, sreverse = newheap()
      local nvalue = 57
      local npayload = {}
      table.insert(sorted, { value = nvalue, payload = npayload })
      sort(sorted)
      heap:insert(nvalue, npayload)
      check(heap)
      testheap(heap, sorted)
    end)

    it("Tests inserting a last item", function()
      local heap, sorted, sreverse = newheap()
      local nvalue = sorted[#sorted].value + 10
      local npayload = {}
      table.insert(sorted, {})
      sorted[#sorted].value = nvalue
      sorted[#sorted].payload = npayload
      heap:insert(nvalue, npayload)
      check(heap)
      testheap(heap, sorted)
    end)
  end)

  describe("Testing updating elements", function()
    it("Tests updating a top item", function()
      local heap, sorted, sreverse = newheap()
      local idx = 1
      local payload = sorted[idx].payload
      local nvalue = sorted[#sorted].value + 1 -- move to end with new value
      sorted[idx].value = nvalue
      sort(sorted)
      heap:update(payload, nvalue)
      check(heap)
      testheap(heap, sorted)
    end)

    it("Tests updating a middle item", function()
      local heap, sorted, sreverse = newheap()
      local idx = 4
      local payload = sorted[idx].payload
      local nvalue = sorted[idx].value * 2
      sorted[idx].value = nvalue
      sort(sorted)
      heap:update(payload, nvalue)
      check(heap)
      testheap(heap, sorted)
    end)

    it("Tests updating a last item", function()
      local heap, sorted, sreverse = newheap()
      local idx = #sorted
      local payload = sorted[idx].payload
      local nvalue = sorted[1].value - 1 -- move to top with new value
      sorted[idx].value = nvalue
      sort(sorted)
      heap:update(payload, nvalue)
      check(heap)
      testheap(heap, sorted)
    end)
  end)

  it("creates minUnique with custom less-than function", function()
    local h = bh.minUnique(function (a, b)
      return math.abs(a) < math.abs(b)
    end)
    h:insert(1, -1)
    check(h)
    h:insert(-2, 2)
    check(h)
    h:insert(3, -3)
    check(h)
    h:insert(-4, 4)
    check(h)
    h:insert(5, -5)
    check(h)
    local value, payload = h:peek()
    assert.equal(1, value)
    assert.equal(-1, payload)
    h:pop()
    check(h)
    local value, payload = h:peek()
    assert.equal(-2, value)
    assert.equal(2, payload)
  end)

  it("get value by payload", function()
    local h = bh.minUnique()
    h:insert(1, -1)
    h:insert(2, -2)
    h:insert(3, -3)
    h:insert(4, -4)
    h:insert(5, -5)
    assert.equal(1, h:valueByPayload((-1)))
    assert.equal(2, h:valueByPayload((-2)))
    assert.equal(3, h:valueByPayload((-3)))
    assert.equal(4, h:valueByPayload((-4)))
    assert.equal(5, h:valueByPayload((-5)))
    h:remove(-1)
    assert.falsy(h:valueByPayload((-1)))
  end)

  it("removes item in minUnique by payload", function()
    local h = bh.minUnique()
    h:insert(1, -1)
    check(h)
    h:insert(2, -2)
    check(h)
    h:insert(3, -3)
    check(h)
    h:insert(4, -4)
    check(h)
    h:insert(5, -5)
    check(h)
    local value, payload = h:peek()
    assert.equal(1, value)
    assert.equal(-1, payload)
    local value, payload = h:remove(-1)
    check(h)
    assert.equal(1, value)
    assert.equal(-1, payload)
    local value, payload = h:peek()
    assert.equal(2, value)
    assert.equal(-2, payload)
  end)

  it("removes item in minUnique (repeated values)",
  function()
    local h = bh.minUnique()
    h:insert(1, 11)
    check(h)
    h:insert(1, 12)
    check(h)
    local value, payload = h:remove(11)
    check(h)
    assert.equal(1, value)
    assert.equal(11, payload)
    local value, payload = h:peek()
    assert.equal(1, value)
    assert.equal(12, payload)
    assert.same({1}, h.values)
    assert.same({12}, h.payloads)
    assert.same({[12]=1}, h.reverse)
  end)
end)

describe("Testing maxUnique heap", function()
  it("creates maxUnique with custom less-than function", function()
    local h = bh.maxUnique(function (a, b)
      return math.abs(a) > math.abs(b)
    end)
    h:insert(1, -1)
    check(h)
    h:insert(-2, 2)
    check(h)
    h:insert(3, -3)
    check(h)
    h:insert(-4, 4)
    check(h)
    h:insert(5, -5)
    check(h)
    local value, payload = h:peek()
    assert.equal(5, value)
    assert.equal(-5, payload)
    h:pop()
    check(h)
    local value, payload = h:peek()
    assert.equal(-4, value)
    assert.equal(4, payload)
  end)
end)

describe("Testing minHeap", function()
  it("creates minHeap", function()
    local h = bh.minHeap()
    check(h)
  end)

  it("inserts a number into minHeap", function()
    local h = bh.minHeap()
    h:insert(42)
    check(h)
  end)

  it("gets peek of empty minHeap", function()
    local h = bh.minHeap()
    assert.falsy(h:peek())
    check(h)
  end)

  it("gets peek of minHeap of one element", function()
    local h = bh.minHeap()
    h:insert(42)
    check(h)
    local value, payload = h:peek()
    assert.equal(42, value)
    assert.falsy(payload)
  end)

  it("gets peek of minHeap of two elements", function()
    local h = bh.minHeap()
    h:insert(42)
    check(h)
    h:insert(1)
    check(h)
    local value, payload = h:peek()
    assert.equal(1, value)
    assert.falsy(payload)
  end)

  it("gets peek of minHeap of 10 elements", function()
    local h = bh.minHeap()
    h:insert(10)
    h:insert(7)
    h:insert(1)
    h:insert(5)
    h:insert(6)
    h:insert(9)
    h:insert(8)
    h:insert(4)
    h:insert(2)
    h:insert(3)
    check(h)
    local value, payload = h:peek()
    assert.equal(1, value)
    assert.falsy(payload)
  end)

  it("removes peek in minHeap of 5 elements", function()
    local h = bh.minHeap()
    h:insert(1)
    h:insert(2)
    h:insert(3)
    h:insert(4)
    h:insert(5)
    local value = h:pop()
    check(h)
    assert.equal(1, value)
    local value = h:peek()
    assert.equal(2, value)
  end)

  it("updates value in minHeap of 5 elements (pos 2 -> pos 1)",
  function()
    local h = bh.minHeap()
    h:insert(1)
    h:insert(2)
    h:insert(3)
    h:insert(4)
    h:insert(5)
    check(h)
    h:update(2, -100)
    check(h)
    local value = h:peek()
    assert.equal(-100, value)
  end)

  it("updates value in minHeap of 5 elements (pos 1 -> pos 2)",
  function()
    local h = bh.minHeap()
    h:insert(1)
    h:insert(2)
    h:insert(3)
    h:insert(4)
    h:insert(5)
    check(h)
    h:update(1, 100)
    check(h)
    local value = h:peek()
    assert.equal(2, value)
  end)

  it("creates minHeap with custom less-than function", function()
    local h = bh.minHeap(function (a, b)
      return math.abs(a) < math.abs(b)
    end)
    h:insert(1)
    check(h)
    h:insert(-2)
    check(h)
    h:insert(3)
    check(h)
    h:insert(-4)
    check(h)
    h:insert(5)
    check(h)
    assert.equal(1, h:peek())
    h:pop()
    check(h)
    assert.equal(-2, h:peek())
  end)
end)

describe("Testing maxHeap", function()
  it("creates maxHeap", function()
    local h = bh.maxHeap()
    check(h)
  end)

  it("inserts a number into maxHeap", function()
    local h = bh.maxHeap()
    h:insert(42)
    check(h)
  end)

  it("gets peek of empty maxHeap", function()
    local h = bh.maxHeap()
    assert.falsy(h:peek())
    check(h)
  end)

  it("gets peek of maxHeap of one element", function()
    local h = bh.maxHeap()
    h:insert(42)
    check(h)
    local value = h:peek()
    assert.equal(42, value)
  end)

  it("gets peek of maxHeap of two elements", function()
    local h = bh.maxHeap()
    h:insert(42)
    check(h)
    h:insert(1)
    check(h)
    local value = h:peek()
    assert.equal(42, value)
  end)

  it("gets peek of maxHeap of 10 elements", function()
    local h = bh.maxHeap()
    h:insert(10)
    h:insert(7)
    h:insert(1)
    h:insert(5)
    h:insert(6)
    h:insert(9)
    h:insert(8)
    h:insert(4)
    h:insert(2)
    h:insert(3)
    check(h)
    local value = h:peek()
    assert.equal(10, value)
  end)

  it("removes peek in maxHeap of 5 elements", function()
    local h = bh.maxHeap()
    h:insert(1)
    h:insert(2)
    h:insert(3)
    h:insert(4)
    h:insert(5)
    check(h)
    local value = h:pop()
    check(h)
    assert.equal(5, value)
    local value = h:peek()
    assert.equal(4, value)
  end)

  it("updates value in maxHeap of 5 elements (pos 2 -> pos 1)",
  function()
    local h = bh.maxHeap()
    h:insert(1)
    h:insert(2)
    h:insert(3)
    h:insert(4)
    h:insert(5)
    check(h)
    h:update(2, 100)
    check(h)
    local value = h:peek()
    assert.equal(100, value)
  end)

  it("updates value in maxHeap of 5 elements (pos 1 -> pos 2)",
  function()
    local h = bh.maxHeap()
    h:insert(1)
    h:insert(2)
    h:insert(3)
    h:insert(4)
    h:insert(5)
    check(h)
    h:update(1, -100)
    check(h)
    local value = h:peek()
    assert.equal(4, value)
  end)

  it("creates maxHeap with custom greater-than function", function()
    local h = bh.maxHeap(function (a, b)
      return math.abs(a) > math.abs(b)
    end)
    h:insert(1)
    check(h)
    h:insert(-2)
    check(h)
    h:insert(3)
    check(h)
    h:insert(-4)
    check(h)
    h:insert(5)
    check(h)
    assert.equal(5, (h:peek()))
    h:pop()
    check(h)
    assert.equal(-4, (h:peek()))
  end)
end)
