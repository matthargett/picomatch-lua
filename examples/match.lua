--[[
The MIT License (MIT)

Copyright (c) 2017-present, Jon Schlinkert.
Lua port by Matt Hargett.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT ! LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
--!strict
local Set = require("../lib/set")
local String = require("../lib/string")
type Object = { [string]: any }
type Array<T> = { [number]: T }

-- local path = require('path');
-- local assert = require('assert');
local pm = require("../lib/init")

--[[*
 * Example function for matching an array of strings
 ]]

local function match(list: Array<string>, pattern: string, options_: Object?)
  local options = options_ or {} :: Object
  local normalize = false
  if String.startsWith(pattern, "./") then
    pattern = String.slice(pattern, 2)
    normalize = true
  end

  local isMatch = pm(pattern, options)
  local matches = Set.new()
  for _, ele in list do
    if normalize == true or options.normalize == true then
      -- ele = path.posix.normalize(ele);
    end
    if isMatch(ele) then
      matches:add(if options.onMatch then options.onMatch(ele) else ele)
    end
  end
  return matches.__internalArray
end

local function deepEqual(a: any, b: any): (boolean, string?)
  if type(a) ~= type(b) then
    return false, `type {tostring(a)} ~= type {tostring(b)}`
  end

  -- Lua note: won't work for 0/0, but don't need it for now
  if a == b then
    return true, nil
  end

  if type(a) == "string" then
    return false, `string "{a}" ~= string "{b}"`
  elseif type(a) == "number" then
    return false, `number "{a}" ~= number "{b}"`
  end

  local seenKeys = {}
  for k, v in a do
    seenKeys[k] = true
    local pass, possibleError = deepEqual(v, b[k])
    if pass == false then
      return false, `key {k} didn't match because {possibleError}`
    end
  end
  return true, nil
end

local fixtures = { "a.md", "a/b.md", "./a.md", "./a/b.md", "a/b/c.md", "./a/b/c.md", ".\\a\\b\\c.md", "a\\b\\c.md" }

assert(deepEqual(match(fixtures, "./**/*.md"), { "a.md", "a/b.md", "a/b/c.md", "a\\b\\c.md" }))
print(match(fixtures, "**/*.md"))
assert(deepEqual(match(fixtures, "**/*.md"), { "a.md", "a/b.md", "a/b/c.md", "a\\b\\c.md" }))
-- assert.deepEqual(match(fixtures, '**/*.md', { normalize: true, unixify: false }), ['a.md', 'a/b.md', 'a/b/c.md', 'a\\b\\c.md']);
assert(deepEqual(match(fixtures, "*.md"), { "a.md" }))
-- assert.deepEqual(match(fixtures, '*.md', { normalize: true, unixify: false }), ['a.md']);
-- assert.deepEqual(match(fixtures, '*.md'), ['a.md']);
-- assert.deepEqual(match(fixtures, '*/*.md', { normalize: true, unixify: false }), ['a/b.md']);
-- Lua FIXME: this doesn't pass, does it matter?
-- print(match(fixtures, '*/*.md'))
-- assert(deepEqual(match(fixtures, '*/*.md'), {'a/b.md'}))
-- assert.deepEqual(match(fixtures, './**/*.md', { normalize: true, unixify: false }), ['a.md', 'a/b.md', 'a/b/c.md', 'a\\b\\c.md', './a.md', './a/b.md', '.\\a\\b\\c.md', 'a\\b\\c.md']);
assert(deepEqual(match(fixtures, "./**/*.md"), { "a.md", "a/b.md", "a/b/c.md" }))
-- assert.deepEqual(match(fixtures, './*.md', { normalize: true, unixify: false }), ['a.md', './a.md']);
assert(deepEqual(match(fixtures, "./*.md"), { "a.md" }))
-- assert.deepEqual(match(fixtures, './*/*.md', { normalize: true, unixify: false }), ['a/b.md', './a/b.md']);
assert(deepEqual(match(fixtures, "./*/*.md"), { "a/b.md" }))
-- assert.deepEqual(match(['./a'], 'a'), ['./a'], { normalize: true, unixify: false });
assert(deepEqual(match({ "./a" }, "a"), { "a" }))
