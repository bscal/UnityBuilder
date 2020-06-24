--[[
local pegasus = require("pegasus")

local server = pegasus:new({
    port='9090',
    location='./root'
})

server:start(function(req, res)
	print("connection")
	local post = req:post()
	print(post)
	
	print(req:method())
	for k, v in pairs(req:headers()) do
		print("header", k,v)
	end
	
end) 
]]