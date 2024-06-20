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

local function makeArg()
    print ([[
    [
        {
            "arguments": {
                "/usr/bin/c++",
                "-c",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-std=c++98",
                "-I./include", 
                "-o",
                "build/request.o",
                "src/request.cpp",
            },
            "directory": "cwd",
            "file\": "path/to/src/file.cpp",
            "output": "path/to/build/file.o"
        }
    ]"]])
end

-- Get context
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
for i, current in ipairs(src_list) do
    print(current)
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
for i, obj_list in ipairs(obj_list) do
    print(obj_list)
end

local filepath = changeLastChar(cwd, '/').. "compile_commands.json"
local outfile = io.open("compile_commands.json", "w")
if not outfile then
    print("Could not open the file for writing!")
    return
end
makeArg()
print("CC created succesfully")

