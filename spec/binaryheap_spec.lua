
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
local reverse = {}
for k,v in pairs(data) do reverse[v.payload] = v end

local function newheap()
  local h = bh.minUnique()
  for i, node in ipairs(data) do
    h:insert(node.value,node.payload)
  end
  return h
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
  
end)
