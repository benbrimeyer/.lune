-- https://github.com/Egor-Skriptunoff/pure_lua_SHA/blob/master/sha2.lua
local base64_symbols = {
    ['+'] = 62, ['-'] = 62,  [62] = '+',
    ['/'] = 63, ['_'] = 63,  [63] = '/',
    ['='] = -1, ['.'] = -1,  [-1] = '='
 }
 local symbol_index = 0
 for j, pair in ipairs{'AZ', 'az', '09'} do
    for ascii = string.byte(pair), string.byte(pair, 2) do
       local ch = string.char(ascii)
       base64_symbols[ch] = symbol_index
       base64_symbols[symbol_index] = ch
       symbol_index = symbol_index + 1
    end
 end

 function bin_to_base64(binary_string)
    local result = {}
    for pos = 1, #binary_string, 3 do
       local c1, c2, c3, c4 = string.byte(string.sub(binary_string, pos, pos + 2)..'\0', 1, -1)
       result[#result + 1] =
          base64_symbols[math.floor(c1 / 4)]
          ..base64_symbols[c1 % 4 * 16 + math.floor(c2 / 16)]
          ..base64_symbols[c3 and c2 % 16 * 4 + math.floor(c3 / 64) or -1]
          ..base64_symbols[c4 and c3 % 64 or -1]
    end
    return table.concat(result)
 end

 return bin_to_base64
