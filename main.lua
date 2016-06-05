--[[
	the main controller of dominos progress
--]]

local Dominos = LibStub('AceAddon-3.0'):GetAddon('Dominos')

local ProgressBarModule = Dominos:NewModule('ProgressBars', 'AceEvent-3.0')

local FRIEND_ID_FACTION_COLOR_INDEX = 5

function ProgressBarModule:Load()		
	self.bars = {
		xp = Dominos.ProgressBar:New('exp'),
		rep = Dominos.ProgressBar:New('rep'),
		artifact = Dominos.ProgressBar:New('artifact')
	}

	self.bars.xp:SetColor(0.58, 0.0, 0.55):SetRestColor(0.25, 0.25, 1)
	self.bars.artifact:SetColor(.901, .8, .601)
	
	self:UpdateXPBar()
	self:UpdateReputationBar()
	
	-- xp bar events
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_XP_UPDATE')
	
	-- reputation events
	self:RegisterEvent('UPDATE_FACTION')
	
	-- artifact events	
	self:RegisterEvent('ARTIFACT_XP_UPDATE')	
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function ProgressBarModule:Unload()
	for i, bar in pairs(self.bars) do
		bar:Free()
	end

	self.bars = {}
end

function ProgressBarModule:PLAYER_ENTERING_WORLD()
	self:UpdateXPBar()
	self:UpdateReputationBar()
	self:UpdateArtifactBar()
end

function ProgressBarModule:PLAYER_XP_UPDATE()
	self:UpdateXPBar()
end

function ProgressBarModule:UPDATE_FACTION(event, unit)
	if unit == 'player' then
		self:UpdateReputationBar()
	end
end

function ProgressBarModule:ARTIFACT_XP_UPDATE()
	self:UpdateArtifactBar()
end

function ProgressBarModule:UNIT_INVENTORY_CHANGED(event, unit)
	if unit == 'player' then
		self:UpdateArtifactBar()
	end
end

function ProgressBarModule:UpdateXPBar()
	local xpBar = self.bars.xp
	local value = UnitXP('player')
	local max = UnitXPMax('player')
	local rest = GetXPExhaustion()
	
	xpBar:SetValue(value, 0, max)
	xpBar:SetRestValue(rest)

	if rest and rest > 0 then
		xpBar:SetText('%s / %s (+%s)', BreakUpLargeNumbers(value), BreakUpLargeNumbers(max), BreakUpLargeNumbers(rest))
	else
		xpBar:SetText('%s / %s', BreakUpLargeNumbers(value), BreakUpLargeNumbers(max))
	end
end

function ProgressBarModule:UpdateReputationBar()
	if not GetWatchedFactionInfo() then return end
	
	local repBar = self.bars.rep
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	
	local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)

	if friendID then
		if nextFriendThreshold then
			min, max, value = friendThreshold, nextFriendThreshold, friendRep
		else
			-- max rank, make it look like a full bar
			min, max, value = 0, 1, 1;
		end
		
		reaction = FRIEND_ID_FACTION_COLOR_INDEX
	else
		friendTextLevel = _G['FACTION_STANDING_LABEL' .. reaction]		
	end

	max = max - min
	value = value - min

	local color = FACTION_BAR_COLORS[reaction]
	
	repBar:SetColor(color.r, color.g, color.b)
	repBar:SetValue(value, 0, max)
	repBar:SetText('%s: %s / %s (%s)', name, BreakUpLargeNumbers(value), BreakUpLargeNumbers(max), friendTextLevel)
end


function ProgressBarModule:UpdateArtifactBar()
	local artifactBar = self.bars.artifact
	
	if not HasArtifactEquipped() then
		artifactBar:SetValue(0, 0, 1)
		artifactBar:SetText('')
		return 
	end
	
	local itemID, altItemID, name, icon, totalXP, pointsSpent = C_ArtifactUI.GetEquippedArtifactInfo()
	
	local numPoints, artifactXP, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
	
	artifactBar:SetValue(artifactXP, 0, xpForNextPoint)
	artifactBar:SetText(ARTIFACT_POWER_BAR, artifactXP, xpForNextPoint)
end


function ProgressBarModule:UpdateHonorBar()
	-- local honorBar = self.bars.honor
	-- local showHonor = newLevel >= MAX_PLAYER_LEVEL and (IsWatchingHonorAsXP() or InActiveBattlefield())

	-- if not showHonor then
	-- 	honorBar:Hide()
	-- 	return
	-- end

	-- local current = UnitHonor("player");
	-- local max = UnitHonorMax("player");
	-- local level = UnitHonorLevel("player");
	-- local levelmax = GetMaxPlayerHonorLevel();

	-- if (level == levelmax) then
	-- 	-- Force the bar to full for the max level
	-- 	statusBar:SetAnimatedValues(1, 0, 1, level);
	-- else
	-- 	statusBar:SetAnimatedValues(current, 0, max, level);
	-- end

	-- HonorExhaustionTick_Update(HonorWatchBar.ExhaustionTick, true);

	-- if (GetHonorRestState() == 1) then
	-- 	statusBar:SetStatusBarColor(1.0, 0.71, 0);
	-- 	statusBar:SetAnimatedTextureColors(1.0, 0.71, 0);
	-- else
	-- 	statusBar:SetStatusBarColor(1.0, 0.24, 0);
	-- 	statusBar:SetAnimatedTextureColors(1.0, 0.24, 0);
	-- end
end