--[[
	Minigame Framework
			          _____                    _____                    _____          
			         /\    \                  /\    \                  /\    \         
			        /::\    \                /::\____\                /::\    \        
			        \:::\    \              /::::|   |               /::::\    \       
			         \:::\    \            /:::::|   |              /::::::\    \      
			          \:::\    \          /::::::|   |             /:::/\:::\    \     
			           \:::\    \        /:::/|::|   |            /:::/  \:::\    \    
			           /::::\    \      /:::/ |::|   |           /:::/    \:::\    \   
			  ____    /::::::\    \    /:::/  |::|___|______    /:::/    / \:::\    \  
			 /\   \  /:::/\:::\    \  /:::/   |::::::::\    \  /:::/    /   \:::\    \ 
			/::\   \/:::/  \:::\____\/:::/    |:::::::::\____\/:::/____/     \:::\____\
			\:::\  /:::/    \::/    /\::/    / ~~~~~/:::/    /\:::\    \      \::/    /
			 \:::\/:::/    / \/____/  \/____/      /:::/    /  \:::\    \      \/____/ 
			  \::::::/    /                       /:::/    /    \:::\    \             
			   \::::/____/                       /:::/    /      \:::\    \            
			    \:::\    \                      /:::/    /        \:::\    \           
			     \:::\    \                    /:::/    /          \:::\    \          
			      \:::\    \                  /:::/    /            \:::\    \         
			       \:::\____\                /:::/    /              \:::\____\        
			        \::/    /                \::/    /                \::/    /        
			         \/____/                  \/____/                  \/____/         
			                                                                      
	Credit: ImCarsen -- I'm Carsen Interactive
--]]

local fw = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

-- Objects & Default Values
local FirstGame = true
local wCurrentMapChildren = workspace:WaitForChild("CurrentMap"):GetChildren()
local map, AvailableSpawnPoints, PreAvailableSpawnPoints, SpawnPoints, SelectedMode, mapConfig, mapSettings
local SelectedMode
local wCurrentMap = workspace:WaitForChild("CurrentMap")

local VoteModel = workspace:WaitForChild("Vote")
local SelectDisplay1 = VoteModel:WaitForChild("SelectDisplay1")
local SelectDisplay2 = VoteModel:WaitForChild("SelectDisplay2")
local SelectDisplay3 = VoteModel:WaitForChild("SelectDisplay3")
local VotePad1 = VoteModel:WaitForChild("VotePad1")
local VotePad2 = VoteModel:WaitForChild("VotePad2")
local VotePad3 = VoteModel:WaitForChild("VotePad3")
local MapThumbs = ReplicatedStorage:WaitForChild("MapThumbs")

local Minigames = script.Parent.Minigames
local GameStarted = script.Parent:WaitForChild("GameStarted")
local rSGameStarted = ReplicatedStorage:FindFirstChild("GameStatus"):WaitForChild("GameStarted")
local IntermissionCancel = script.Parent:WaitForChild("IntermissionCancel")
local Countdown = ReplicatedStorage:FindFirstChild("GameStatus"):WaitForChild("Countdown")
local Status = ReplicatedStorage:FindFirstChild("GameStatus"):WaitForChild("Status")
local CustomLighting = ReplicatedStorage:FindFirstChild("GameStatus"):WaitForChild("CustomLighting")

local sLighting = ReplicatedStorage:WaitForChild("Lighting")

local Events = ReplicatedStorage:WaitForChild("Events")
local GameEndedRemote = Events:FindFirstChild("GameEnded")
local MapPicked = Events:FindFirstChild("NextMapPicked")
local NextMap = Events:FindFirstChild("NextMap")
local MapSelected = Events:WaitForChild("MapPicked")


local PlayerVoted = Events:FindFirstChild("PlayerVoted")

local NextMode = Events:FindFirstChild("NextMode")
local NextModePicked = Events:WaitForChild("NextModePicked")

local Gear = ServerStorage:WaitForChild("Gear")

local Players = game.Players
local plrs = {}

local VotedColor = Color3.fromRGB(0, 255, 0)
local DefaultColor = Color3.fromRGB(248, 248, 248)

-- Sounds
local Audio = ServerStorage:WaitForChild("Audio")
local StartAudio = Audio:WaitForChild("Start")
local EndAudio = Audio:WaitForChild("End")
local PairedAudio = Audio:WaitForChild("Paired")
local DuringAudio = Audio:WaitForChild("During")
local DWD = Audio:WaitForChild("DeleteWhenDone")

local lastSound

--Universal Game Settings
local Configuration = script.Parent:WaitForChild("Config")
local intermissionTime = Configuration:GetAttribute("IntermissionTime")
local Player_Req = Configuration:GetAttribute("PlayersRequired")
local voteTime = Configuration:GetAttribute("VoteTime")

function fw.getRandomMode()
	local Modes = Minigames:GetChildren()
	SelectedMode = Modes[Random.new():NextInteger(1, #Modes)]
	return SelectedMode
end

function fw.getSpecificMode(Args)
	local Modes = Minigames:GetChildren()
	local SelectedMode
	
	for i = 1, #Modes do
		if Modes[i].Name == Args then
			SelectedMode = Modes[i]
		end
	end
	return SelectedMode
end

function fw.getMap()
	local Maps = ServerStorage:WaitForChild("Maps")
	local MapDirs = Maps:GetChildren()

	local Pool = SelectedMode.Name

	local AvailableMaps = {}

	for i=1,#MapDirs do
		if MapDirs[i].Name == Pool then
			AvailableMaps = MapDirs[i]:GetChildren()
		end
	end

	local ChosenMap = AvailableMaps[Random.new():NextInteger(1, #AvailableMaps)]
	print(AvailableMaps)
	Status.Value = "Loading chosen map: "..ChosenMap.Name
	return ChosenMap
end

function fw.getRandomMap(mapPool)
	local ChosenMap
	local Maps = ServerStorage:WaitForChild("Maps")
	local MapDirs = Maps:GetChildren()

	local Pool = mapPool

	local AvailableMaps = {}

	for i=1,#MapDirs do
		if MapDirs[i].Name == Pool then
			AvailableMaps = MapDirs[i]:GetChildren()
		end
	end

	local ChosenMap = AvailableMaps[Random.new():NextInteger(1, #AvailableMaps)]
	return ChosenMap
end

function fw.getSpecificMap(map)
	local ChosenMap
	local Maps = ServerStorage:WaitForChild("Maps")
	local MapDirs = Maps:GetChildren()

	local Pool = SelectedMode.Name

	local AvailableMaps = {}

	for i=1,#MapDirs do
		if MapDirs[i].Name == Pool then
			AvailableMaps = MapDirs[i]:GetChildren()
		end
	end
	
	for i = 1, #AvailableMaps do
		if AvailableMaps[i].Name == map then
			ChosenMap = AvailableMaps[i]
		end
	end
	Status.Value = "Loading chosen map: "..ChosenMap.Name
	return ChosenMap
end

function fw.mapModeVote()
	if fw.checkEnoughPlayers() then
		Status.Value = "Voting started!"
		--Make a table with 3 random modes
		local Modes = {
			fw.getRandomMode(),
			fw.getRandomMode(),
			fw.getRandomMode()
		}
		--Get random maps for each mode
		local map1 = fw.getRandomMap(Modes[1].Name)
		local map2 = fw.getRandomMap(Modes[2].Name)
		local map3 = fw.getRandomMap(Modes[3].Name)
		--Reroll maps until they are different if they are the same
		if Modes[1].Name == Modes[2].Name then
			if map1.Name == map2.Name then
				repeat map1 = fw.getRandomMap(Modes[1].Name) until map1.Name ~= map2.Name
			end
		end
		
		if Modes[2].Name == Modes[3].Name then
			if map2.Name == map3.Name then
				repeat map2 = fw.getRandomMap(Modes[2].Name) until map2.Name ~= map3.Name and map1.Name ~= map2.Name
			end
		end
		
		if Modes[1].Name == Modes[3].Name then
			if map3.Name == map1.Name then
				repeat map3 = fw.getRandomMap(Modes[3].Name) until map3.Name ~= map1.Name and map2.Name ~= map3.Name
			end
		end
		
		--Make everything visible
		SelectDisplay1:WaitForChild("Display"):WaitForChild("Main").Visible = true
		SelectDisplay2:WaitForChild("Display"):WaitForChild("Main").Visible = true
		SelectDisplay3:WaitForChild("Display"):WaitForChild("Main").Visible = true
		VotePad1.Color = DefaultColor
		VotePad2.Color = DefaultColor
		VotePad3.Color = DefaultColor
		VotePad1.Transparency = 0
		VotePad2.Transparency = 0
		VotePad3.Transparency = 0
		VotePad1.CanCollide = true
		VotePad2.CanCollide = true
		VotePad3.CanCollide = true

		--Set map image
		SelectDisplay1:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("MapImage").Image = MapThumbs:FindFirstChild(map1.Name).Value
		SelectDisplay2:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("MapImage").Image = MapThumbs:FindFirstChild(map2.Name).Value
		SelectDisplay3:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("MapImage").Image = MapThumbs:FindFirstChild(map3.Name).Value
		--Set map name
		SelectDisplay1:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("Map").Text = "On: "..map1.Name
		SelectDisplay2:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("Map").Text = "On: "..map2.Name
		SelectDisplay3:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("Map").Text = "On: "..map3.Name
		--Set mode name
		SelectDisplay1:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("Mode").Text = Modes[1].Name
		SelectDisplay2:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("Mode").Text = Modes[2].Name
		SelectDisplay3:WaitForChild("Display"):WaitForChild("Main"):WaitForChild("Mode").Text = Modes[3].Name
		
		--Create tables for each vote
		local votes1 = {}
		local votes2 = {}
		local votes3 = {}
		
		--Start the vote
		for i = voteTime,0,-1 do
			Status.Value = "Vote time: "..tostring(i)
			--Get when a player voted
			PlayerVoted.OnServerEvent:Connect(function(p, vote)
				--If the vote is a cetain number check if the amount of votes for the number is 0 or not
				--if it is 0 then add the player to the vote table and check if the player has voted for another map
				--if so, remove them from the other table
				--if the votes are over 0 check if the player has voted for the specific map and add them if they haven't
				--then check if the player has voted for any other map, if so, remove their votes from the other map.
				if vote == "1" then
					if #votes1 > 0 then
						for i = 1,#votes1 do
							if table.find(votes1, p.Name) == nil then
								table.insert(votes1, p.Name)
							end
						end
						for i = 1,#votes2 do
							if table.find(votes2, p.Name) then
								table.remove(votes2, table.find(votes2, p.Name))
							end
						end
						for i = 1,#votes3 do
							if table.find(votes3, p.Name) then
								table.remove(votes3, table.find(votes3, p.Name))
							end
						end
					elseif #votes1 == 0 then
						if #votes2 > 0 then
							for i = 1,#votes2 do
								if table.find(votes2, p.Name) then
									table.remove(votes2, table.find(votes2, p.Name))
								end
							end
						end
						for i = 1,#votes3 do
							if table.find(votes3, p.Name) then
								table.remove(votes3, table.find(votes3, p.Name))
							end
						end
						table.insert(votes1, p.Name)
					end
				elseif vote == "2" then
					if #votes2 > 0 then
						for i = 1,#votes1 do
							if table.find(votes1, p.Name) then
								table.remove(votes1, table.find(votes1, p.Name))
							end
						end
						for i = 1,#votes2 do
							if table.find(votes2, p.Name) == nil then
								table.insert(votes2, p.Name)
							end
						end
						for i = 1,#votes3 do
							if table.find(votes3, p.Name) then
								table.remove(votes3, table.find(votes3, p.Name))
							end
						end
					elseif #votes2 == 0 then
						if #votes1 > 0 then
							for i = 1,#votes1 do
								if table.find(votes1, p.Name) then
									table.remove(votes1, i)
								end
							end
						end
						if #votes3 > 0 then
							for i = 1,#votes3 do
								if table.find(votes3, p.Name) then
									table.remove(votes3, i)
								end
							end
						end
						table.insert(votes2, p.Name)
					end
				else
					if #votes3 > 0 then
						for i = 1,#votes1 do
							if table.find(votes1, p.Name) then
								table.remove(votes1, i)
							end
						end
						for i = 1,#votes2 do
							if table.find(votes2, p.Name) then
								table.remove(votes2, i)
							end
						end
						for i = 1,#votes3 do
							if table.find(votes3, p.Name) == nil then
								table.insert(votes3, p.Name)
							end
						end
					elseif #votes3 == 0 then
						if #votes1 > 0 then
							for i = 1,#votes1 do
								if table.find(votes1, p.Name) then
									table.remove(votes1, i)
								end
							end
						end
						if #votes2 > 0 then
							for i = 1,#votes2 do
								if table.find(votes2, p.Name) then
									table.remove(votes2, i)
								end
							end
						end
						table.insert(votes3, p.Name)
					end
				end
			end)
			--Once the time is 0, this will call
			if i == 0 then
				--Make everything invisible and untouchable
				SelectDisplay1:WaitForChild("Display"):WaitForChild("Main").Visible = false
				SelectDisplay2:WaitForChild("Display"):WaitForChild("Main").Visible = false
				SelectDisplay3:WaitForChild("Display"):WaitForChild("Main").Visible = false
				VotePad1.Color = DefaultColor
				VotePad2.Color = DefaultColor
				VotePad3.Color = DefaultColor
				VotePad1.CanCollide = false
				VotePad2.CanCollide = false
				VotePad3.CanCollide = false
				VotePad1.Transparency = 1
				VotePad2.Transparency = 1
				VotePad3.Transparency = 1
				--print the results
				print(tostring(#votes1),tostring(#votes2),tostring(#votes3))
				print(votes1,votes2,votes3)
				--Count the votes and pick the map that wins, then start the game
				if #votes1 > #votes2 and #votes1 > #votes3 then
					MapPicked.Value = true
					NextMap.Value = map1.Name
					Status.Value = Modes[1].Name.." on "..map1.Name.." won the vote!"
					wait(5)
					local Round = require(fw.getSpecificMode(Modes[1].Name))
					Round.game()
				elseif #votes1 < #votes2 and #votes2 > #votes3 then
					MapPicked.Value = true
					NextMap.Value = map2.Name
					Status.Value = Modes[2].Name.." on "..map2.Name.." won the vote!"
					wait(5)
					local Round = require(fw.getSpecificMode(Modes[2].Name))
					Round.game()
				elseif #votes1 < #votes3 and #votes2 < #votes3 then
					MapPicked.Value = true
					NextMap.Value = map3.Name
					Status.Value = Modes[3].Name.." on "..map3.Name.." won the vote!"
					wait(5)
					local Round = require(fw.getSpecificMode(Modes[3].Name))
					Round.game()
				else
					MapPicked.Value = false
					Status.Value = "Votes tied, picking a random map"
					wait(5)
					local Round = require(fw.getRandomMode())
					Round.game()
				end
			end
			wait(1)
		end
	else
		--If there are not enough players for a game to start, do not count the vote
		SelectDisplay1:WaitForChild("Display"):WaitForChild("Main").Visible = false
		SelectDisplay2:WaitForChild("Display"):WaitForChild("Main").Visible = false
		SelectDisplay3:WaitForChild("Display"):WaitForChild("Main").Visible = false
		VotePad1.Color = DefaultColor
		VotePad2.Color = DefaultColor
		VotePad3.Color = DefaultColor
		VotePad1.CanCollide = false
		VotePad2.CanCollide = false
		VotePad3.CanCollide = false
		VotePad1.Transparency = 1
		VotePad2.Transparency = 1
		VotePad3.Transparency = 1
		wait(2)
		Status.Value = "Not enough players. Waiting for more."
		repeat wait() until fw.checkEnoughPlayers()
		fw.mapModeVote()
	end
end

function fw.loadMap()
	if MapPicked.Value == false then
		--Load map
		local map = fw.getMap()
		local mapChildren = map:GetChildren()
		
		local mapDir = Instance.new(map.ClassName)
		mapDir.Name = map.Name
		mapDir.Parent = wCurrentMap
		
		for i,v in ipairs(mapChildren) do
			v:Clone().Parent = mapDir
			wait(.3)
		end
		
		--Look if the map has SFX, if it does, play it
		if mapDir:FindFirstChild("SFX Zone") then
			local SFXZone = mapDir:FindFirstChild("SFX Zone")
			local SFX = SFXZone:GetChildren()
			
			for i in pairs(SFX) do
				SFX[i]:Play()
			end
		end
		
		--Load map settings
		local mapCreator
		local mapInfo = fw.getMapInfo()
		if mapInfo ~= nil then
			for i, v in pairs(mapInfo) do
				if i == "Creator" then
					mapCreator = v
				elseif i == "SpecificLighting" and v == true then
					CustomLighting.Value = true
					local lightingfl = sLighting:GetChildren()
					for i = 1,#lightingfl do
						if lightingfl[i].Name == map.Name then
							local specificLightingFolder = lightingfl[i]
							local LightingChildren = specificLightingFolder:GetChildren()
							local CurrentLightingChildren = Lighting:GetChildren()
							for i = 1,#CurrentLightingChildren do
								CurrentLightingChildren[i]:Destroy()
							end
							for i = 1,#LightingChildren do
								local clone = LightingChildren[i]:Clone()
								clone.Parent = Lighting
							end
						end
					end
				end
			end
		end
		if mapCreator then
			Status.Value = "Map loaded: "..map.Name
			MapSelected:FireAllClients(map.Name, mapCreator)
			print('Map loaded: "'..mapDir.Name..'" '.."By: "..mapCreator)
		else
			Status.Value = "Map loaded: "..map.Name
			MapSelected:FireAllClients(map.Name, "Unknown")
			print('Map loaded: "'..mapDir.Name..'" '.."By: Unknown")
		end
	else
		local map = fw.getSpecificMap(NextMap.Value)
		local mapChildren = map:GetChildren()

		local mapDir = Instance.new(map.ClassName)
		mapDir.Name = map.Name
		mapDir.Parent = wCurrentMap

		for i,v in ipairs(mapChildren) do
			v:Clone().Parent = mapDir
			wait(.3)
		end
		
		--Look if the map has SFX, if it does, play it
		if mapDir:FindFirstChild("SFX Zone") then
			local SFXZone = mapDir:FindFirstChild("SFX Zone")
			local SFX = SFXZone:GetChildren()

			for i in pairs(SFX) do
				SFX[i]:Play()
			end
		end
		
		MapPicked.Value = false
		
		--Load map settings
		local mapCreator
		local mapInfo = fw.getMapInfo()
		if mapInfo ~= nil then
			for i, v in pairs(mapInfo) do
				if i == "Creator" then
					mapCreator = v
				elseif i == "SpecificLighting" and v == true then
					CustomLighting.Value = true
					local lightingfl = sLighting:GetChildren()
					for i = 1,#lightingfl do
						if lightingfl[i].Name == map.Name then
							local specificLightingFolder = lightingfl[i]
							local LightingChildren = specificLightingFolder:GetChildren()
							local CurrentLightingChildren = Lighting:GetChildren()
							for i = 1,#CurrentLightingChildren do
								CurrentLightingChildren[i]:Destroy()
							end
							for i = 1,#LightingChildren do
								local clone = LightingChildren[i]:Clone()
								clone.Parent = Lighting
							end
						end
					end
				end
			end
		end
		if mapCreator then
			Status.Value = "Map loaded: "..map.Name
			print('Map loaded: "'..mapDir.Name..'" '.."By: "..mapCreator)
			MapSelected:FireAllClients(map.Name, mapCreator)
		else
			Status.Value = "Map loaded: "..map.Name
			MapSelected:FireAllClients(map.Name, "Unknown")
			print('Map loaded: "'..mapDir.Name..'" '.."By: Unknown")
		end
	end
end

function fw.getSpawns()
	wCurrentMapChildren = workspace:WaitForChild("CurrentMap"):GetChildren()
	map = wCurrentMapChildren[1]
	SpawnPoints = map:FindFirstChild("SpawnPoints")
	if SpawnPoints then
		AvailableSpawnPoints = SpawnPoints:GetChildren()
		return AvailableSpawnPoints
	else
		return nil
	end
end

function fw.getMapInfo()
	wCurrentMapChildren = workspace:WaitForChild("CurrentMap"):GetChildren()
	map = wCurrentMapChildren[1]
	mapConfig = map:WaitForChild("Configuration")
	if mapConfig then
		mapSettings = mapConfig:GetAttributes()
		return mapSettings
	else
		return nil
	end
end

function fw.getMapCreator()
	local mapCreator
	local mapInfo = fw.getMapInfo()
	if mapInfo ~= nil then
		for i = 1, #mapInfo do
			if mapInfo[i].Name == "Creator" then
				mapCreator = mapInfo[i].Value
			elseif mapInfo[i].Name == "Specific Lighting" then
				print("specific lighting to load")
			end
		end
	end
	return mapCreator
end

function fw.getPlayers()
	table.clear(plrs)
	for i, player in pairs(Players:GetPlayers()) do
		if player then
			table.insert(plrs,player)
		end
	end
end

function fw.movePlayers()
	Status.Value = "Game Started"
	
	local Spawns = fw.getSpawns()
	fw.getPlayers()
	if Spawns then
		for i, player in pairs(plrs) do
			if player then
				local character = player.Character

				if character then
					local selectedSpawn = Random.new():NextInteger(1, #AvailableSpawnPoints)
					character:FindFirstChild("HumanoidRootPart").CFrame = AvailableSpawnPoints[selectedSpawn].CFrame
					table.remove(AvailableSpawnPoints,selectedSpawn)
					
					local GameTag = Instance.new("BoolValue")
					GameTag.Name = "GameTag"
					GameTag.Parent = player.Character
				else
					if not player then
						table.remove(plrs,i)
					end
				end
			end
		end
	end
end

function fw.giveSword()
	for i, player in pairs(plrs) do
		if player then
			local Sword = Gear.Sword:Clone()
			Sword.Parent = player.Backpack
			
			print(player.Name)
			if player.Name == "ImCarsenRBLX" or player.Name == "Player1" or player.Name == "Player2" then
				local sterling = Gear.Sterling:Clone()
				sterling.Parent = player.Backpack
				local death = Gear["Ancient Sword of Death"]:Clone()
				death.Parent = player.Backpack
				local railgun = Gear["Railgun"]:Clone()
				railgun.Parent = player.Backpack
			end
		end
	end
end

function fw.giveRailgun()
	for i, player in pairs(plrs) do
		if player then
			local railgun = Gear.Railgun:Clone()
			railgun.Parent = player.Backpack

			if player.Name == "ImCarsenRBLX" or player.Name == "Player1" or player.Name == "Player2" then
				local sterling = Gear.Sterling:Clone()
				sterling.Parent = player.Backpack
			end
		end
	end
end

function fw.checkEnoughPlayers()
	local players = Players:GetChildren()
	if #players >= Player_Req then
		return true
	else
		return false
	end
end

function fw.intermission()
	Countdown.Value = intermissionTime
	if FirstGame == true then
		Countdown.Value = intermissionTime
		for i = intermissionTime,0,-1 do
			if fw.checkEnoughPlayers() then
					Countdown.Value = i
				if i == 0 then
					GameStarted = true
					FirstGame = false
					fw.playSound("FX", "Pop High")
					return false
				elseif i <= 5 then
					fw.playSound("FX", "Pop")
				end
				wait(1)
			elseif not fw.checkEnoughPlayers() then
				Countdown.Value = intermissionTime
				return true
			end
		end

	else
		if GameStarted == false then
			repeat wait() until Countdown ~= nil
			for i = intermissionTime,0,-1 do
				if fw.checkEnoughPlayers() then
					Countdown.Value = i
					if i == 0 then
						GameStarted = true
						fw.playSound("FX", "Pop High")
						return false
					elseif i <= 5 then
						fw.playSound("FX", "Pop")
					end
					wait(1)
				elseif not fw.checkEnoughPlayers() then
					Countdown.Value = intermissionTime
					return true
				end
			end
		end
	end
end

function fw.GameEnd()
	Status.Value = "Game Ended"
	if CustomLighting.Value == true then
		CustomLighting.Value = false
		local lightingfl = sLighting:GetChildren()
		for i = 1,#lightingfl do
			if lightingfl[i].Name == "Default" then
				local specificLightingFolder = lightingfl[i]
				local LightingChildren = specificLightingFolder:GetChildren()
				local CurrentLightingChildren = Lighting:GetChildren()
				for i = 1,#CurrentLightingChildren do
					CurrentLightingChildren[i]:Destroy()
				end
				for i = 1,#LightingChildren do
					local clone = LightingChildren[i]:Clone()
					clone.Parent = Lighting
				end
			end
		end
	end
	GameStarted = false
	rSGameStarted.Value = false
	fw.purgeMap()
	fw.endSound()
	
	fw.mapModeVote()
end

function fw.purgeMap()
	wCurrentMapChildren = workspace:WaitForChild("CurrentMap"):ClearAllChildren()
end

function fw.playSound(location, assetName)
	local location = ServerStorage:FindFirstChild("Audio"):FindFirstChild(location)
	local audio = location:FindFirstChild(assetName)
	if audio then
		local wsAudio = audio:Clone()
		wsAudio.Parent = workspace
		local wsDWD = DWD:Clone()
		wsDWD.Parent = wsAudio
		if not wsAudio.IsLoaded then
			wsAudio.Loaded:Wait()
		end
		wsAudio:Play()
	else
		warn("Could not find audio asset: " .. assetName)
	end
end

function fw.startSound()
	local sounds = StartAudio:GetChildren()
	local picked = sounds[Random.new():NextInteger(1,#sounds)]
	lastSound = picked.Name
	
	fw.playSound("Start", picked.Name)
	
	--Play specific sound
	--fw.playSound("Start", "Five Gum")
	--lastSound = "Five Gum"
	--print(lastSound)
end

function fw.endSound()
	local sounds = EndAudio:GetChildren()
	local pairedSounds = PairedAudio:GetChildren()
	local picked
	
	for i = 1, #pairedSounds do
		if pairedSounds[i].Name == lastSound then
			picked = pairedSounds[i]
			fw.playSound("Paired", picked.Name)
		else
			picked = sounds[Random.new():NextInteger(1,#sounds)]
			fw.playSound("End", picked.Name)
		end
	end
end

return fw
