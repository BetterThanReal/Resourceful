local function findResource(state, resourceName)
  for _, target in ipairs(state.searchTargets) do
    target = target:FindFirstChild(resourceName, false)
    if target then
      return target
    end
  end
end

local function isErr(err)
  return type(err) == 'table' and err.msg ~= nil
end

local function getErrMsg(err)
  if isErr(err) then
    return err.msg
  else
    return err
  end
end

local function doError(libraryName, err, level, onError, onErrorEvent)
  level = level or 0
  level = level + (level == 0 and 0 or 1)

  if onError or onErrorEvent then
    local errMsg = getErrMsg(err)
    local name = libraryName or "script"

    if onErrorEvent then
      onErrorEvent:Fire(errMsg, name)
    end

    if onError then
      pcall(onError, errMsg, name)
    end
  end

  error(err, level)
end

local function getErrScope(libraryName)
  if libraryName then
    return (
      "library '%s'. Please consult the installation instructions for '%s'"
      ):format(libraryName, libraryName)
  else
    return "a script"
  end
end

local function getErrLoad(libraryName, errMsg, loading)
  return ({ msg = (
    "Resourceful was unable to load required resources for '%s' in %s. " ..
    "ERROR: %s"):format(
      table.concat(loading, "', '"), getErrScope(libraryName), errMsg) })
end

local function getErrRequire(libraryName, errMsg, resourceName)
  return ({ msg = (
    "Resourceful was unable to require resource '%s' in %s. " ..
    "ERROR: %s"):format(
      resourceName, getErrScope(libraryName), errMsg) })
end

local function getSearchTargets(libraryName, searchTargets)
  if searchTargets == nil then
    doError(libraryName, (
      "Resourceful was initialized without search targets for %s."
      ):format(getErrScope(libraryName)), 0)
  end

  if typeof(searchTargets) == 'Instance' then
    return { searchTargets }
  end

  if type(searchTargets) ~= 'table' then
    doError(libraryName, (
      "Resourceful was initialized with an invalid search target for %s. "
      ):format(getErrScope(libraryName)), 0)
  end

  if #searchTargets == 0 then
    doError(libraryName, (
      "Resourceful was initialized with empty search targets for %s. "
      ):format(getErrScope(libraryName)), 0)
  end

  local targets = {}
  local unique = {}

  for _, target in ipairs(searchTargets) do
    if typeof(target) ~= 'Instance' then
      doError(libraryName, (
        "Resourceful was initialized with an invalid search target for %s. "
        ):format(getErrScope(libraryName)), 0)
    end

    if not unique[target] then
      unique[target] = true
      targets[#targets + 1] = target
    end
  end

  return targets
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

  if resource == nil and loader == nil and state.isStrict then
    doError(state.name, getErrLoad(
      state.name,
      "Resource was neither found nor defined, and strict mode is enabled",
      state.loading), 0)
  end

  if loader ~= nil then
    local status
    status, resource = pcall(loader, state.resources, resource)

    if not status then
      if isErr(resource) then
        doError(state.name, resource, 0)
      else
        doError(
          state.name,
          getErrLoad(state.name, resource, state.loading), 0)
      end
    end

    if resource == nil and state.isStrict then
      doError(state.name, getErrLoad(
        state.name,
        "The resource function returned nil, and strict mode is enabled",
        state.loading), 0)
    end
  end

  if resource == nil and state.isStrict then
    doError(state.name, getErrLoad(
      state.name, "No such resource was found, and strict mode is enabled",
      state.loading), 0)
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
    doError(
      state.name,
      getErrLoad(
        state.name, "Circular dependency encountered", state.loading), 0)
  end

  state.loadingLookup[resourceName] = true
  state.loading[#state.loading + 1] = resourceName

  local status, resource = pcall(getOrLoadResource, state, resourceName)

  state.loadingLookup[resourceName] = false
  state.loading[#state.loading] = nil

  if not status then
    doError(state.name, resource, 0)
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

    doError(
      state.name,
      getErrRequire(
        state.name, "Resource is not a ModuleScript", resourceName), 0)
  end

  local status
  status, required = pcall(require, required)

  if not status then
    doError(
      state.name,
      getErrRequire(state.name, required, resourceName), 0)
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

local function getErrorHandlers(onError, onErrorEvent, name)
  local isInvalidOnError = onError ~= nil and typeof(onError) ~= 'function'

  local isInvalidOnErrorEvent = onErrorEvent ~= nil and
    not(typeof(onErrorEvent) == 'Instance' and
      onErrorEvent.ClassName == 'BindableEvent')

  if isInvalidOnError then
    onError = nil
  end

  if isInvalidOnErrorEvent then
    onErrorEvent = nil
  end

  local errMsg = nil

  if isInvalidOnError then
    errMsg = (
      "Resourceful was initialized with a non-function value " ..
      "for onError in %s."):format(getErrScope(name))

  elseif isInvalidOnErrorEvent then
    errMsg = (
      "Resourceful was initialized with a non-BindableEvent value for " ..
      "onErrorEvent in %s."):format(getErrScope(name))
  end

  return onError, onErrorEvent, errMsg
end

create = function(table, options)
  options = options or {}
  options.search = options.search or script.Parent 

  local name = options.name or nil
  local onError = options.onError or nil
  local onErrorEvent = options.onErrorEvent or nil

  do
    local errMsg
    onError, onErrorEvent, errMsg = getErrorHandlers(
      onError, onErrorEvent, name)

    if errMsg then
      doError(name, errMsg, 2, onError, onErrorEvent)
    end
  end

  do
    local status
    status, searchTargets = pcall(
      getSearchTargets, name, options.search, onError, onErrorEvent)

    if not status then
      doError(name, searchTargets, 2, onError, onErrorEvent)
    end
  end

  local resources = {}

  local state = {
    isCached = options.isCached == true or options.isCached == nil,
    isStrict = options.isStrict ~= false,
    loaders = options.resources or {},
    loading = {},
    loadingLookup = {},
    name = name,
    onError = onError,
    onErrorEvent = onErrorEvent,
    requires = {},
    resources = resources,
    searchTargets = searchTargets,
  }

  setmetatable(state.requires, {
    __index = function(table, index)
      local status, requires = pcall(getRequire, state, index)

      if not status then
        if #state.loading > 0 then
          doError(name, requires, 0)
        else
          doError(name, getErrMsg(requires), 2, onError, onErrorEvent)
        end
      end

      return requires
    end,
  })

  resources.require = state.requires

  setmetatable(resources, {
    __call = create,

    __index = function(table, index)
      local status, resource = pcall(getResource, state, index)

      if not status then
        if #state.loading > 0 then
          doError(name, resource, 0)
        else
          doError(name, getErrMsg(resource), 2, onError, onErrorEvent)
        end
      end

      return resource
    end,
  })

  do
    local status, message = pcall(initLoaders, state)
    if not status then
      doError(name, getErrMsg(message), 2, onError, onErrorEvent)
    end
  end

  return resources
end

return create()