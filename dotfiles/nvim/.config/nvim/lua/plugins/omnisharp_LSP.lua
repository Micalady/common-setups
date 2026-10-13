-- omnisharp-roslyn: https://github.com/OmniSharp/omnisharp-roslyn


-- NOTE: the following lines needs to go in Directory.Build.props
-- <PropertyGroup>
--   ...
--   <NuGetAudit>false</NuGetAudit>
--   ...
-- </PropertyGroup>

-- NOTE: at this point in time, this file will be used mainly for reference

local M = {}

function os.capture(cmd, raw)
  if raw == nil then raw = true end
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

local global_json = '/global.json'
-- ~/.local/share/nvim/lazy
local data_dir = vim.fn.stdpath('data')
local omnisharp_wd = data_dir .. '/lazy/omnisharp-roslyn'
local target_file = omnisharp_wd .. global_json
local dotnet_ver = os.capture('dotnet --version')
local current_dir = os.capture('pwd')

-- ---@param plug LazyPlugin
---@param plug any
function M.checkout_branch_by_tag(plug)
  if plug.tag == nil then return end
  os.execute('cd ' .. omnisharp_wd .. ' && git checkout ' .. plug.tag)
end

function M.read_write_file()
  os.execute('cd ' .. omnisharp_wd .. ' && git reset --hard && cd -')
  local file = assert(io.open(target_file, 'r'))
  local data = file:read('*all')
  local data_json = vim.json.decode(data)
  local str_part = {}
  for str in string.gmatch(dotnet_ver, "([^%s]+)") do
    table.insert(str_part, str)
  end
  assert(str_part[1])
  dotnet_ver = str_part[1]
  data_json.sdk.version = dotnet_ver
  data = vim.json.encode(data_json)
  file:close()
  file = assert(io.open(target_file, 'w'))
  file:write(data, '\n')
  file:close()
end

function M.build_omnisharp()
  local build_cmd_win = 'PowerShell -File ' .. omnisharp_wd .. '/build.ps1 -target Quick'
  local build_cmd_unix = 'bash ' .. omnisharp_wd .. '/build.sh --target Quick'
  local uname = assert(vim.loop.os_uname().sysname)
  uname = string.lower(uname)
  local is_windows = string.find(uname, 'windows')
  if is_windows then
    os.execute(build_cmd_win)
  else
    os.execute(build_cmd_unix)
  end
end

return {
--   url = 'https://github.com/OmniSharp/omnisharp-roslyn',
--   tag = 'v1.39.13',
--   build = function(plug)
--     M.checkout_branch_by_tag(plug)
--     M.read_write_file()
--     -- M.build_omnisharp()
--   end,
--   config = function(plug, opts)
--     -- M.checkout_branch_by_tag(plug)
--     -- M.read_write_file()
--   end,
}
