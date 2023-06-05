local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local Datastore = require(ReplicatedStorage.Packages.datastore2)

local SpawnArea = workspace.SpawnArea
local Tree = game.ServerStorage.Items.Tree
local TreeFolder = workspace.Trees
local Connections = {}

local Service = Knit.CreateService({
	Name = "TreeService",
	Client = {},
})

function Service:RandomiseSpawn()
	local x, _x = SpawnArea.Size.X / 2, SpawnArea.Position.X - SpawnArea.Size.X / 2
	local z, _z = SpawnArea.Size.Z / 2, SpawnArea.Position.Z - SpawnArea.Size.Z / 2

	local x_ = math.random(_x, x) --// _x : negative | x : positive
	local z_ = math.random(_z, z) --// _z : negative | z : positive

	return Vector3.new(x_, 7.5, z_)
end

function Service:RandomiseOrientation()
	local r = math.random(-180, 180)
	return CFrame.Angles(0, math.rad(r), 0)
end

function Service:Destroy(ProximityPrompt: ProximityPrompt, Player: Player)
	local tree = ProximityPrompt.Parent.Parent.Parent
	local Cash = Datastore("Cash", Player)
    local Explosion: Explosion = Instance.new("Explosion")

    Explosion.Parent = tree

    Explosion.BlastPressure = 20
    Explosion.BlastRadius = 20
    

	ProximityPrompt.Parent:Destroy()

	Cash:Increment(10)

	for _, Part in pairs(tree:GetDescendants()) do
		if Part:IsA("MeshPart") then
			Part.Anchored = false
		end
	end

    Explosion.Visible = true

	task.wait(5)
	Tree:Destroy()
end


function Service:Spawn()
	if (#workspace.Trees:GetChildren() <= 50) then
		local location = self:RandomiseSpawn()
		local orientation = self:RandomiseOrientation()
		local treeNew = Tree:Clone()
		treeNew.Parent = TreeFolder
		treeNew:SetPrimaryPartCFrame(orientation)
		treeNew:MoveTo(location)

        for _, ProximityPrompt: ProximityPrompt in pairs(treeNew:GetDescendants()) do
            if ProximityPrompt:IsA("ProximityPrompt") then
                Connections[treeNew] = ProximityPrompt.Triggered:Connect(function(User: Player)
                    self:Destroy(ProximityPrompt, User)
                end)
            end
        end

		if (treeNew.PrimaryPart.Position.Y > 7.75) then
			treeNew:Destroy()
			self:Spawn()
		end
	end
end

function Service:KnitStart()
	print(`[{Service.Name}] Started`)

    while task.wait(5) do
        self:Spawn()
    end
end

return Service
