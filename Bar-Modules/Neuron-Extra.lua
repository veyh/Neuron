--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local CDB

NEURON.NeuronExtraBar = NEURON:NewModule("ExtraBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronExtraBar = NEURON.NeuronExtraBar


local XBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local xbarsCDB
local xbtnsCDB

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local gDef = {
	hidestates = ":extrabar0:",
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = 0,
	y = 205,
}

local configData = {
	stored = false,
}

local keyData = {
	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = true,
}


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronExtraBar:OnInitialize()

	CDB = NeuronCDB

	xbarsCDB = CDB.xbars
	xbtnsCDB = CDB.xbtns

	----------------------------------------------------------------
	XBTN.SetData = NeuronExtraBar.SetData
	XBTN.LoadData = NeuronExtraBar.LoadData
	XBTN.SaveData = NeuronExtraBar.SaveData
	XBTN.SetAux = NeuronExtraBar.SetAux
	XBTN.LoadAux = NeuronExtraBar.LoadAux
	XBTN.SetObjectVisibility = NeuronExtraBar.SetObjectVisibility
	XBTN.SetDefaults = NeuronExtraBar.SetDefaults
	XBTN.GetDefaults = NeuronExtraBar.GetDefaults
	XBTN.SetType = NeuronExtraBar.SetType
	XBTN.GetSkinned = NeuronExtraBar.GetSkinned
	XBTN.SetSkinned = NeuronExtraBar.SetSkinned
	----------------------------------------------------------------

	NEURON:RegisterBarClass("extrabar", "ExtraActionBar", L["Extra Action Bar"], "Extra Action Button", xbarsCDB, xbarsCDB, NeuronExtraBar, xbtnsCDB, "CheckButton", "NeuronActionButtonTemplate", { __index = XBTN }, 1, gDef, nil, false)

	NEURON:RegisterGUIOptions("extrabar", { AUTOHIDE = true,
		SHOWGRID = false,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		HIDDEN = true,
		LOCKBAR = true,
		TOOLTIPS = true,
		BINDTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true }, false, 65)

	if (CDB.xbarFirstRun) then

		local bar = NEURON.NeuronBar:CreateNewBar("extrabar", 1, true)
		local object = NEURON.NeuronButton:CreateNewObject("extrabar", 1)

		NEURON.NeuronBar:AddObjectToList(bar, object)

		CDB.xbarFirstRun = false

	else

		for id,data in pairs(xbarsCDB) do
			if (data ~= nil) then
				NEURON.NeuronBar:CreateNewBar("extrabar", id)
			end
		end

		for id,data in pairs(xbtnsCDB) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("extrabar", id)
			end
		end
	end

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronExtraBar:OnEnable()

	NeuronExtraBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronExtraBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------

function NeuronExtraBar:DisableDefault()

	local disableExtraButton = false

	for i,v in ipairs(NEURON.NeuronExtraBar) do

		if (v["bar"]) then --only disable if a specific button has an associated bar
			disableExtraButton = true
		end
	end


	if disableExtraButton then
		------Hiding the default blizzard
		ExtraActionButton1:UnregisterAllEvents()
		ExtraActionButton1:SetPoint("BOTTOM", 0, -250)
		MainMenuBarVehicleLeaveButton:UnregisterAllEvents()
		MainMenuBarVehicleLeaveButton:SetPoint("BOTTOM", 0, -250)
	end

end


function NeuronExtraBar:GetSkinned(button)
	--empty
end

function NeuronExtraBar:SetSkinned(button)

	if (SKIN) then

		local bar = button.bar

		if (bar) then

			local btnData = {
				Icon = button.icontexture,
				Normal = button.normaltexture,

			}

			SKIN:Group("Neuron", bar.gdata.name):AddButton(button, btnData)

		end

	end
end

function NeuronExtraBar:SaveData(button)

	-- empty

end

function NeuronExtraBar:LoadData(button, spec, state)

	local id = button.id

	button.CDB = xbtnsCDB

	if (button.CDB) then

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].config) then
			button.CDB[id].config = CopyTable(configData)
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id].data) then
			button.CDB[id].data = {}
		end

		NEURON:UpdateData(button.CDB[id].config, configData)
		NEURON:UpdateData(button.CDB[id].keys, keyData)

		button.config = button.CDB [id].config

		if (CDB.perCharBinds) then
			button.keys = button.CDB[id].keys
		else
			button.keys = button.CDB[id].keys
		end

		button.data = button.CDB[id].data
	end
end

function NeuronExtraBar:SetObjectVisibility(button, show)

	if HasExtraActionBar() or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		button:SetAlpha(1)
	elseif not NEURON.ButtonEditMode and not NEURON.BarEditMode and not NEURON.BindingMode then
		button:SetAlpha(0)
	end

end

function NeuronExtraBar:SetAux(button)


end

function NeuronExtraBar:SetExtraButtonTex(button)

	if button.actionID then
		button.iconframeicon:SetTexture(GetActionTexture(button.actionID))
	end

	local texture = GetOverrideBarSkin() or "Interface\\ExtraButton\\Default"
	button.style:SetTexture(texture)
end


function NeuronExtraBar:LoadAux(button)

	NEURON.NeuronBinder:CreateBindFrame(button, button.objTIndex)
	NeuronExtraBar:CreateVehicleLeave(button, button.objTIndex)

	button.style = button:CreateTexture(nil, "OVERLAY")
	button.style:SetPoint("CENTER", -2, 1)
	button.style:SetWidth(190)
	button.style:SetHeight(95)

	NeuronExtraBar:SetExtraButtonTex(button)

	button.hotkey:SetPoint("TOPLEFT", -4, -6)
end

function NeuronExtraBar:SetDefaults(button)

	-- empty

end

function NeuronExtraBar:GetDefaults(button)

	--empty

end

function NeuronExtraBar:SetData(button, bar)
	NEURON.NeuronButton:SetData(button, bar)
end


function NeuronExtraBar:ExtraButton_Update(button)

	NeuronExtraBar:SetExtraButtonTex(button)

	if xbarsCDB[1].border then
		button.style:Show()
	else
		button.style:Hide()
	end

	local start, duration, enable = GetActionCooldown(button.actionID);

	if (start) then
		NEURON.NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end
end


function NeuronExtraBar:SetType(button, save)

	button:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	button:RegisterEvent("ZONE_CHANGED")
	button:RegisterEvent("SPELLS_CHANGED")

	button.actionID = 169

	button:SetAttribute("type", "action")
	button:SetAttribute("*action1", self.actionID)

	button:SetAttribute("useparent-unit", false)
	button:SetAttribute("unit", ATTRIBUTE_NOOP)

	button:SetScript("OnEvent", function(self, event, ...) NeuronExtraBar:OnEvent(self, event, ...) end)
	button:HookScript("OnShow", function(self) NeuronExtraBar:ExtraButton_Update(self) end)

	button:WrapScript(button, "OnShow", [[
					for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
						self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
					end
					]])

	button:WrapScript(button, "OnHide", [[
					if (not self:GetParent():GetAttribute("concealed")) then
						for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
							self:ClearBinding(key)
						end
					end
					]])

	button:SetSkinned(button)
end


function NeuronExtraBar:OnEvent(button, event, ...)

	NeuronExtraBar:ExtraButton_Update(button)
	button:SetObjectVisibility(button)

end


----------------------------------------------------------------------------
-----------------------------Vehicle Leave Button---------------------------
----------------------------------------------------------------------------


function NeuronExtraBar:VehicleLeave_OnEvent(button, event, ...)
	if (event == "UPDATE_EXTRA_ACTIONBAR") then
		button:Hide()
	end

	if (ActionBarController_GetCurrentActionBarState) then
		if (CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == 1) then
			button:Show()
			button:Enable();
			if UnitOnTaxi("player") then
				button.iconframeicon:SetTexture(NEURON.SpecialActions.taxi)
			else
				button.iconframeicon:SetTexture(NEURON.SpecialActions.vehicle)
			end
		else
			button:Hide()
		end
	end
end



function NeuronExtraBar:VehicleLeave_OnEnter(button)
	if ( UnitOnTaxi("player") ) then

		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:ClearLines()
		GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

function NeuronExtraBar:VehicleLeave_OnClick(button)
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding();

		-- Show that the request for landing has been received.
		button:Disable();
		button:SetHighlightTexture([[Interface\Buttons\CheckButtonHilight]], "ADD");
		button:LockHighlight();
	else
		VehicleExit();
	end
end


function NeuronExtraBar:CreateVehicleLeave(button, index)
	button.vlbtn = CreateFrame("Button", button:GetName().."VLeave", UIParent, "NeuronNonSecureButtonTemplate")

	button.vlbtn:SetAllPoints(button)

	button.vlbtn:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	button.vlbtn:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	button.vlbtn:RegisterEvent("UPDATE_POSSESS_BAR");
	button.vlbtn:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
	button.vlbtn:RegisterEvent("UPDATE_EXTRA_ACTIONBAR");
	button.vlbtn:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	button.vlbtn:RegisterEvent("UNIT_ENTERED_VEHICLE")
	button.vlbtn:RegisterEvent("UNIT_EXITED_VEHICLE")
	button.vlbtn:RegisterEvent("VEHICLE_UPDATE")

	button.vlbtn:SetScript("OnEvent", function(self, event, ...) NeuronExtraBar:VehicleLeave_OnEvent(self, event, ...) end)
	button.vlbtn:SetScript("OnClick", function(self) NeuronExtraBar:VehicleLeave_OnClick(self) end)
	button.vlbtn:SetScript("OnEnter", function(self) NeuronExtraBar:VehicleLeave_OnEnter(self) end)
	button.vlbtn:SetScript("OnLeave", GameTooltip_Hide)

	local objects = NEURON:GetParentKeys(button.vlbtn)

	for k,v in pairs(objects) do
		local name = (v):gsub(button.vlbtn:GetName(), "")
		button.vlbtn[name:lower()] = _G[v]
	end

	button.vlbtn.iconframeicon:SetTexture(NEURON.SpecialActions.vehicle)

	button.vlbtn:SetFrameLevel(4)
	button.vlbtn.iconframe:SetFrameLevel(2)
	button.vlbtn.iconframecooldown:SetFrameLevel(3)

	button.vlbtn:Hide()
end