if CCLuaLog then
  io.output():setvbuf("no")
elseif ngx and ngx.log then
  function print(...)
    local arg = {
      ...
    }
    for k, v in pairs(arg) do
      arg[k] = tostring(v)
    end
    ngx.log(ngx.ERR, table.concat(arg, "\t"))
  end
end
echo = print
function printf(fmt, ...)
  echo(string.format(tostring(fmt), ...))
end
function echoError(fmt, ...)
  echoLog("ERR", fmt, ...)
  print(debug.traceback("", 2))
end
function echoInfo(fmt, ...)
  echoLog("INFO", fmt, ...)
end
function echoLog(tag, fmt, ...)
  echo(string.format("[%s] %s", string.upper(tostring(tag)), string.format(tostring(fmt), ...)))
end
function throw(errorType, fmt, ...)
  local arg = {
    ...
  }
  for k, v in pairs(arg) do
    arg[k] = tostring(v)
  end
  local msg = string.format(tostring(fmt), unpack(arg))
  error(string.format("<<%s>> - %s", tostring(errorType), msg), 2)
end
function dump(object, label, isReturnContents, nesting)
  if type(nesting) ~= "number" then
    nesting = 99
  end
  local lookupTable = {}
  local result = {}
  local _v = function(v)
    if type(v) == "string" then
      v = "\"" .. v .. "\""
    end
    return tostring(v)
  end
  local traceback = string.split(debug.traceback("", 2), "\n")
  echo("dump from: " .. string.trim(traceback[3]))
  local function _dump(object, label, indent, nest, keylen)
    label = label or "<var>"
    spc = ""
    if type(keylen) == "number" then
      spc = string.rep(" ", keylen - string.len(_v(label)))
    end
    if type(object) ~= "table" then
      result[#result + 1] = string.format("%s%s%s = %s", indent, _v(label), spc, _v(object))
    elseif lookupTable[object] then
      result[#result + 1] = string.format("%s%s%s = *REF*", indent, label, spc)
    else
      lookupTable[object] = true
      if nest > nesting then
        result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, label)
      else
        result[#result + 1] = string.format("%s%s = {", indent, _v(label))
        local indent2 = indent .. "    "
        local keys = {}
        local keylen = 0
        local values = {}
        for k, v in pairs(object) do
          keys[#keys + 1] = k
          local vk = _v(k)
          local vkl = string.len(vk)
          if keylen < vkl then
            keylen = vkl
          end
          values[k] = v
        end
        table.sort(keys, function(a, b)
          if type(a) == "number" and type(b) == "number" then
            return a < b
          else
            return tostring(a) < tostring(b)
          end
        end)
        for i, k in ipairs(keys) do
          _dump(values[k], k, indent2, nest + 1, keylen)
        end
        result[#result + 1] = string.format("%s}", indent)
      end
    end
  end
  _dump(object, label, "- ", 1)
  if isReturnContents then
    return table.concat(result, "\n")
  end
  for i, line in ipairs(result) do
    echo(line)
  end
end
function vardump(object, label)
  local lookupTable = {}
  local result = {}
  local _v = function(v)
    if type(v) == "string" then
      v = "\"" .. v .. "\""
    end
    return tostring(v)
  end
  local function _vardump(object, label, indent, nest)
    label = label or "<var>"
    local postfix = ""
    if nest > 1 then
      postfix = ","
    end
    if type(object) ~= "table" then
      if type(label) == "string" then
        result[#result + 1] = string.format("%s%s = %s%s", indent, label, _v(object), postfix)
      else
        result[#result + 1] = string.format("%s%s%s", indent, _v(object), postfix)
      end
    elseif not lookupTable[object] then
      lookupTable[object] = true
      if type(label) == "string" then
        result[#result + 1] = string.format("%s%s = {", indent, label)
      else
        result[#result + 1] = string.format("%s{", indent)
      end
      local indent2 = indent .. "    "
      local keys = {}
      local values = {}
      for k, v in pairs(object) do
        keys[#keys + 1] = k
        values[k] = v
      end
      table.sort(keys, function(a, b)
        if type(a) == "number" and type(b) == "number" then
          return a < b
        else
          return tostring(a) < tostring(b)
        end
      end)
      for i, k in ipairs(keys) do
        _vardump(values[k], k, indent2, nest + 1)
      end
      result[#result + 1] = string.format("%s}%s", indent, postfix)
    end
  end
  _vardump(object, label, "", 1)
  return table.concat(result, "\n")
end
function printTable(tab, tabN)
  if tabN == nil then
    tabN = 0
  end
  for k, v in pairs(tab) do
    local str = ""
    for t = 1, tabN do
      str = str .. "\t"
    end
    print(str .. tostring(k) .. ": " .. tostring(v))
    if type(v) == "table" then
      printTable(v, tabN + 1)
    end
  end
end
