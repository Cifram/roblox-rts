local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Symbol = require(script.Parent.Symbol)

local Component = {}
Component.__index = Component

function Component:getComponent(component)
	return component._instances[self.instance]
end

function Component:getComponentInParent(component)
	-- objects removed from the data model will have the instance removed signal fired on them, so the component will be detached
	assert(self.instance.Parent, "Component's instance has no parent")
	return component._instances[self.instance.Parent]
end

function Component:getComponentsInDescendants(component)
	local components = {}
	for _,instance in pairs(self.instance:GetDescendants()) do
		local object = component._instances[instance]
		if object then
			components[#components+1] = object
		end
	end
	return components
end

function Component:getComponentOnInstance(instance, component)
	return component._instances[instance]
end

function Component:getInstancesWithComponent(component)
	local instances = {}
	for instance in pairs(component._instances) do
		instances[#instances+1] = instance
	end
	return instances
end

function Component:init()
end

function Component:destroy()
end

Component._components = {}
Component._queued = {}
Component.InitedFlag = Symbol.new("wasInited")

function Component:extend(name, defaultProps)
	local Class = {}
	Class.__index = Class
	setmetatable(Class, self)
	-- begin only magical part of :extend()
	Class.className = name
	Class._instances = {}
	self._components[name] = Class
	-- end magic

	function Class.new(instance)
		local component = {
			instance = instance,
		}
		for key, value in pairs(defaultProps or {}) do
			component[key] = value
		end
		setmetatable(component, Class)

		return component
	end

	return Class
end

function Component._setup()
	for _,component in pairs(Component._components) do
		local function attach(instance)
			local object = component.new(instance)
			object[Component.InitedFlag] = false
			component._instances[instance] = object
			Component._queued[#Component._queued+1] = object
			
			return component
		end

		local function detach(instance)
			local object = component._instances[instance]
			if object[Component.InitedFlag] then
				object:removed()
			end
			object:destroy()
			component._instances[instance] = nil
		end

		for _,instance in pairs(CollectionService:GetTagged(component.className)) do
			attach(instance)
		end
		CollectionService:GetInstanceAddedSignal(component.className):Connect(attach)
		CollectionService:GetInstanceRemovedSignal(component.className):Connect(detach)
	end
end

function Component._update(dt)
	for _, component in pairs(Component._components) do
		-- only update components that have a update method
		if component.update then
			debug.profilebegin(string.format("Stepping %s components", component.className))
			for _, object in pairs(component._instances) do
				object:update(dt)
			end
			debug.profileend()
		end
	end
end

-- call this as late as possible, or at least after _update
function Component._processQueue()
	local queue = Component._queued
	Component._queued = {}
	for i = 1, #queue do
		local comp = queue[i]
		if not comp[Component.InitedFlag] then
			comp[Component.InitedFlag] = true
			queue[i]:init()
		end
	end
end

return Component