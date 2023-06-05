local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

Knit.Start()
	:andThen(function()
		print("[CLIENT] Knit started")
	end)
	:catch(error)

