
local bh = require('binaryheap')

local data = {
  { value = 98, payload = {} }, -- 1
  { value = 28, payload = {} }, -- 2
  { value = 36, payload = {} }, -- 3
  { value = 48, payload = {} }, -- 4
  { value = 68, payload = {} }, -- 5
  { value = 58, payload = {} }, -- 6
  { value = 80, payload = {} }, -- 7
  { value = 46, payload = {} }, -- 8
  { value = 19, payload = {} }, -- 9
  { value = 66, payload = {} }, -- 10
  { value = 22, payload = {} }, -- 11
  { value = 60, payload = {} }, -- 12
  { value = 15, payload = {} }, -- 13
  { value = 83, payload = {} }, -- 14 
  { value = 59, payload = {} }, -- 15
}

local sort = function(t)
  table.sort(t, function(a,b) return (a.value < b.value) end)
  return t
end

local function newheap()
  -- create a heap with data
  local heap = bh.minUnique()
  for _, node in ipairs(data) do
    heap:insert(node.value,node.payload)
  end
  
  -- create a sorted list with data, sorted by 'value'
  local sorted = {}
  for k,v in pairs(data) do sorted[k] = v end
  sort(sorted)
  
  -- create a reverse list of the sorted table; returns sorted-index, based on 'value'
  local sreverse = {}
  for i,v in ipairs(sorted) do sreverse[v.value] = i end
  
  return heap, sorted, sreverse
end

local function testheap(heap, sorted)
  while sorted[1] do    
    local payload1, value1 = heap:pop()
    local payload2, value2 = sorted[1].payload, sorted[1].value
    table.remove(sorted, 1)
    assert.are.equal(payload1, payload2)
    assert.are.equal(value1, value2)
  end
end


describe("Testing MaxUnique heap", function()

  it("tests order of insertion", function()
    local h = newheap()
    assert.are.equal(h[1].payload, data[13].payload)
    assert.are.equal(h[2].payload, data[11].payload)
    assert.are.equal(h[3].payload, data[9].payload)
    assert.are.equal(h[4].payload, data[8].payload)
    assert.are.equal(h[5].payload, data[2].payload)
    assert.are.equal(h[6].payload, data[3].payload)
    assert.are.equal(h[7].payload, data[15].payload)
    assert.are.equal(h[8].payload, data[1].payload)
    assert.are.equal(h[9].payload, data[4].payload)
    assert.are.equal(h[10].payload, data[5].payload)
    assert.are.equal(h[11].payload, data[10].payload)
    assert.are.equal(h[12].payload, data[12].payload)
    assert.are.equal(h[13].payload, data[6].payload)
    assert.are.equal(h[14].payload, data[14].payload)
    assert.are.equal(h[15].payload, data[7].payload)
    
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
    assert.are.equal(value, heap[1].value)
    assert.are.equal(payload, heap[1].payload)
  end)

  describe("Testing removing elements", function()
      
    it("Tests removing a middle item", function()
      local heap, sorted, sreverse = newheap()
      local idx = 4
      local value = sorted[idx].value
      local payload = sorted[idx].payload
      local pl, v = heap:remove(payload)
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
      local idx = #heap
      local value = sorted[idx].value
      local payload = sorted[idx].payload
      local pl, v = heap:remove(payload)
      -- did we get the right ones?
      assert.are.equal(value, v)
      assert.are.equal(payload, pl)
      assert.is.Nil(heap[payload])
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
      testheap(heap, sorted)
    end)
    
    it("Tests inserting a middle item", function()
      local heap, sorted, sreverse = newheap()
      local nvalue = 57
      local npayload = {}
      table.insert(sorted, { value = nvalue, payload = npayload })
      sort(sorted)
      heap:insert(nvalue, npayload)
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
      testheap(heap, sorted)
    end)
  
  end)

end)
