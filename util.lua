function round_to_nth_decimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5) / mult
end

function print_table(table, name)
  print("==================")
  if name then print("Printing table: " .. name) end
  for k, v in pairs(table) do
    if type(v) == "table" then
      print("[table]: " .. tostring(k))
      for key, val in pairs(v) do
        print(" *[key]: " .. tostring(key) .. " | [value]: " .. tostring(val))
      end
    else
      print("[key]: " .. tostring(k) .. " | [value]: " .. tostring(v))
    end
  end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function within_variance(val1, val2, variance)
  local diff = math.abs(val1 - val2)
  if diff < variance then
    return true
  else
    return false
  end
end

function math.clamp(val, min, max)
    if min - val > 0 then
        return min
    end
    if max - val < 0 then
        return max
    end
    return val
end
