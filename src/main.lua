-- needed because lua strings are immutable
local function changeLastChar(str, newChar)
    local len = #str
    if len == 0 then
        return newChar
    end
    local substr = string.sub(str, 1, len - 1)
    return substr .. newChar
end

local function changeExt(str, src, obj)
    local s_len = #str
    if s_len == 0 then
        return obj 
    end
    local substr = string.sub(str, 1, s_len - #src)
    return substr .. obj 
end
local function getExitStatus(handle)
    local exit_status, exit_code, exit_signal = handle:close()
    return exit_status
end

local function findFiles(dir, filetype)
    local ret = "ls ./"..dir.. "/*."..filetype
    return ret
end

local function split(str, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in (str .. delimiter):gmatch(pattern) do
        table.insert(result, match)
    end
    return result
end

local function cutPath(path)
    local filename = path:match(".*/(.*)")
    return filename 
end

local function makeArg(filename, cwd, src_dir, obj_dir)
    local ret = 
[[ 
	{
		"arguments": [
			"/usr/bin/c++",
			"-c",
			"-Wall",
			"-Wextra",
			"-Werror",
			"-std=c++98",
			"-I./include/", 
			"-o",
			"build/]]..filename..[[.o",
			"src/]]..filename..[[.cpp"
		],
		"directory": "]]..changeLastChar(cwd, "")..[[",
		"file": "]]..cwd..src_dir.."/"..filename..[[.cpp",
		"output":"]]..cwd..obj_dir.."/"..filename..[[.o"
	}
]]
	return ret
end

--[[Get context
print("Enter src dir:")
local src_path = io.read()
print("Enter build dir:")
local obj_path = io.read()
print("Enter include dir:")
local inc_path = io.read()
print("Enter compiler:")
local compiler = io.read()
print("Enter compile flags:")
local c_flags = io.read()
--]]

local src_path = "src"
local obj_path = "build"
local inc_path = "include"
local compiler = "c++"
local c_flags = "-Wall -Wextra -Werror"
print([=[
Running default mode :
src_path -> src/
obj_path -> build/
compiler -> c++
c_flags -> -Wall -Wextra -Werror
]=])

local handle = io.popen("pwd")
local cwd = handle:read("*a")
if not getExitStatus(handle) then
   print("Error getting current working directory")
   return
end

local command = findFiles(src_path, "cpp")
local handle = io.popen(command)
local src_list= split(handle:read("*a"), '\n')
if not getExitStatus(handle) then
   print("Error finding sources")
   return
end
for i, current in ipairs(src_list) do
    src_list[i] = cutPath(current)
end
--local command = findFiles(obj_path, "o")
--local handle = io.popen(command)
--local obj_list = handle:read("*a")
--if not getExitStatus(handle) then
--   print("Error finding objects")
--   return
--end
local obj_list = {}
for i, src_list in ipairs(src_list) do
    table.insert(obj_list, changeExt(src_list, "cpp" , "o"))
end

local cwd = changeLastChar(cwd, '/')
local filepath = cwd .. "compile_commands.json"
local outfile = io.open("compile_commands.json", "w")
if not outfile then
    print("Could not open the file for writing!")
    return
end
outfile:write("[");
for i, current in ipairs(obj_list) do
	outfile:write(makeArg(changeExt(current,".o", ""), cwd, src_path, obj_path))
end
outfile:write("]\n");
outfile.close()
print("CC created succesfully")
return 0

