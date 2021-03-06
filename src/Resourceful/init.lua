local function findResource(state, resourceName)
  for _, target in ipairs(state.searchTargets) do
    target = target:FindFirstChild(resourceName, false)
    if target then
      return target
    end
  end
end

local function getNameForErr(name)
  return name and (" for %s"):format(name) or ''
end

local function getRefLabel(ref)
  local t = typeof(ref)

  if t == 'Instance' then
    local cn = type(ref.ClassName) == 'string' and
      ref.ClassName ~= '' and ref.ClassName

    local n = type(ref.name) == 'string' and
      ref.name ~= '' and ref.name

    return ("<%s>%s"):format(
      cn or 'Instance', n and (' "%s"'):format(n) or '')
  else
    if t == 'string' then
      return '"' .. ref .. '"'
    elseif t == 'boolean' or t == 'number' or ref == nil then
      return tostring(ref)
    else
      return '<' .. t .. '>'
    end
  end
end

local function getResourceErr(err, state)
  local name = getNameForErr((state or {}).name)
  local context = ''

  local loading = (state or {}).loading or {}
  if #loading > 0 then
    context = (" while resolving '%s'"):format(table.concat(loading, "', '"))
  end

  return (err):format(("%s%s"):format(name, context))
end

local function getSearchTargets(name, search)
  if typeof(search) == 'Instance' then
    return { search }
  end

  if search == nil then
    return { script.Parent }
  end

  if type(search) ~= 'table' then
    error((
      "Invalid value for property 'search' in argument #1 'options' " ..
      "to Resourceful()%s " ..
      "(Instance or table of Instance objects expected, received %s)"
      ):format(getNameForErr(name), getRefLabel(search)), 0)
  end

  local targets = {}
  local unique = {}

  for _, target in ipairs(search) do
    if typeof(target) ~= 'Instance' then
      error((
        "Invalid value for property 'search' in argument #1 'options' " ..
        "to Resourceful()%s (Instance or table of Instance objects " ..
        "expected, received table with %s)"
        ):format(getNameForErr(name), getRefLabel(target)), 0)
    end

    if not unique[target] then
      unique[target] = true
      targets[#targets + 1] = target
    end
  end

  return targets
end

local function isResourcefulError(err)
  return string.find(err, "Resourceful ") ~= nil
end

local function loadResource(state, resourceName)
  local loader = state.loaders[resourceName]

  if loader ~= nil and type(loader) ~= 'function' then
    return loader
  end

  local resource = nil

  if resourceName ~= '__init' then
    resource = findResource(state, resourceName)
  end

  if loader ~= nil then
    local status
    status, resource = pcall(loader, state.resources, resource)

    if not status then
      if isResourcefulError(resource) then
        error(resource, 0)
      else
        error(getResourceErr((
          "Resourceful resource function '%s' encountered an error" ..
          "%%s. ERROR: %s"):format(resourceName, resource), state), 0)
      end
    end

    if resource == nil and state.isStrict then
      error(getResourceErr((
        "Resourceful resource function '%s' returned nil%%s, " ..
        "and strict mode is enabled"):format(resourceName), state), 0)
    end
  end

  if resource == nil and state.isStrict then
    error(getResourceErr((
      "Resourceful resource '%s' was neither found nor defined%%s, " ..
      "and strict mode is enabled"):format(resourceName), state), 0)
  end

  return resource
end

local function getOrLoadResource(state, resourceName)
  local resource = rawget(state.resources, resourceName)

  if resource then
    return resource
  end

  resource = loadResource(state, resourceName)

  if state.isCached then
    state.resources[resourceName] = resource
  end

  return resource
end

local function getResource(state, resourceName)
  if state.loadingLookup[resourceName] then
    error(getResourceErr(
      "Resourceful encountered a circular dependency%s", state), 0)
  end

  state.loadingLookup[resourceName] = true
  state.loading[#state.loading + 1] = resourceName

  local status, resource = pcall(getOrLoadResource, state, resourceName)

  state.loadingLookup[resourceName] = false
  state.loading[#state.loading] = nil

  if not status then
    error(resource, 0)
  end

  return resource
end

local function getRequire(state, resourceName)
  local required = rawget(state.requires, resourceName)

  if required then
    return required
  end

  required = getResource(state, resourceName)

  if typeof(required) ~= 'Instance' or
    required.ClassName ~= 'ModuleScript' then

    error(getResourceErr((
      "Resourceful attempted to require non-ModuleScript resource '%s'%%s"
      ):format(resourceName), state), 0)
  end

  local status
  status, required = pcall(require, required)

  if not status then
    error(getResourceErr((
      "Resourceful encountered an error requiring module '%s'%%s"
      ):format(resourceName), state), 0)
  end

  if state.isCached then
    state.requires[resourceName] = required
  end

  return required
end

local function initLoaders(state)
  if rawget(state.loaders, '__init') then
    -- Invoke __init like a typical resource, to cache its results.
    getResource(state, '__init')
  end
end

local create = nil

local function _create(_table, options)
  if options ~= nil and type(options) ~= 'table' then
    error((
      "Invalid value for argument #1 'options' to Resourceful() " ..
      "(table expected, received %s)"):format(getRefLabel(options)), 2)
  end

  options = options or {}
  local isCached = options.isCached
  local isStrict = options.isStrict
  local loaders = options.resources
  local name = options.name

  if name ~= nil and type(name) ~= 'string' then
    error((
      "Invalid value for property 'name' in argument #1 'options' " ..
      "to Resourceful() (string expected, received %s)"
      ):format(getRefLabel(name)), 2)
  end

  if isCached ~= nil and type(isCached) ~= 'boolean' then
    error((
      "Invalid value for property 'isCached' in argument #1 'options' " ..
      "to Resourceful()%s (boolean expected, received %s)"
      ):format(getNameForErr(name), getRefLabel(isCached)), 2)
  else
    isCached = isCached ~= false
  end

  if isStrict ~= nil and type(isStrict) ~= 'boolean' then
    error((
      "Invalid value for property 'isStrict' in argument #1 'options' " ..
      "to Resourceful()%s (boolean expected, received %s)"
      ):format(getNameForErr(name), getRefLabel(isStrict)), 2)
  else
    isStrict = isStrict ~= false
  end

  if loaders ~= nil and type(loaders) ~= 'table' then
    error((
      "Invalid value for property 'loaders' in argument #1 'options' " ..
      "to Resourceful()%s (table expected, received %s)"
      ):format(getNameForErr(name), getRefLabel(loaders)), 2)
  else
    loaders = loaders or {}
  end

  local state = {
    isCached = isCached,
    isStrict = isStrict,
    loaders = loaders,
    loading = {},
    loadingLookup = {},
    name = name,
    requires = {},
    resources = {},
    searchTargets = getSearchTargets(name, options.search),
  }

  setmetatable(state.requires, {
    __index = function(_table, index)
      local status, requires = pcall(getRequire, state, index)

      if not status then
        if #state.loading > 0 then
          error(requires, 0)
        else
          error(requires, 2)
        end
      end

      return requires
    end,
  })

  local resources = state.resources
  resources.require = state.requires

  setmetatable(resources, {
    __call = create,

    __index = function(_table, index)
      local status, resource = pcall(getResource, state, index)

      if not status then
        if #state.loading > 0 then
          error(resource, 0)
        else
          error(resource, 2)
        end
      end

      return resource
    end,
  })

  do
    local status, message = pcall(initLoaders, state)
    if not status then
      error(message, 2)
    end
  end

  return resources
end

create = function(...)
  local status, resources = pcall(_create, ...)

  if not status then
    error(resources, 2)
  end

  return resources
end

return create()