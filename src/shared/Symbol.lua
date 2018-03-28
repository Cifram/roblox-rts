local Symbol = {}

function Symbol.new(name)
	local self = newproxy(true)

	getmetatable(self).__tostring = function()
		return ("Symbol(%s)"):format(name)
	end

	return self
end

return Symbol