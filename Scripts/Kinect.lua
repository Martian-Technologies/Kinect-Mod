---@diagnostic disable: need-check-nil
Kinect = class()
Kinect.maxParentCount = 1 
Kinect.maxChildCount = -1 -- infinite
Kinect.connectionInput = sm.interactable.connectionType.seated + sm.interactable.connectionType.power
Kinect.connectionOutput = sm.interactable.connectionType.power
Kinect.colorNormal = sm.color.new(0xffff00ff)
Kinect.colorHighlight = sm.color.new(0xffff55ff)
LoaderID = nil
kinectstuff = {"SpineBase",
"SpineMid",
"Neck",
"Head",
"ShoulderLeft",
"ElbowLeft",
"WristLeft",
"HandLeft",
"ShoulderRight",
"ElbowRight",
"WristRight",
"HandRight",
"HipLeft",
"KneeLeft",
"AnkleLeft",
"FootLeft",
"HipRight",
"KneeRight",
"AnkleRight",
"FootRight",
"SpineShoulder",
"HandTipLeft",
"ThumbLeft",
"HandTipRight",
"ThumbRight"
}
XYZ = {"X   (Left and Right)","Y   (Up and down)","Z   (Back and Front)"}
function Kinect.server_onMelee(self)

	local table = self.storage:load()
	table[2] = table[2] + 1
	if table[2] > 2 then
		table[2] = 0
	end
	self.storage:save(table)
	self.table = self.storage:load()
	sm.gui.chatMessage( string.format("XYZ:     	%s",XYZ[table[2]+1]) )
	print(string.format("XYZ: %s",XYZ[table[2]+1]))


	self.network:sendToClients('clientTable', self.table)
end

function Kinect.server_onProjectile(self)

	local table = self.storage:load()
	table[1] = table[1] + 1
	if table[1] > 24 then
		table[1] = 0
	end
	self.storage:save(table)
	self.table = self.storage:load()

	print(string.format("Joint Type: %s",table[1]))
	sm.gui.chatMessage( string.format("Joint Type: %s",table[1]) )
	sm.gui.chatMessage( string.format("Joint Name: %s",kinectstuff[table[1]+1]) )
	print(string.format("Joint Name: %s",kinectstuff[table[1]+1]))
	self.network:sendToClients('clientTable', self.table)
end
function Kinect.clientTable(self, tbl)
	self.table = tbl
end

function Kinect.tryImportData(self)
	if LoaderID == nil then
		LoaderID = self.interactable:getId()
	end
	if self.interactable:getId() == LoaderID then
		if pcall(self.tryImport) then
			--print(AllJointPositions[1])
			return true
		else
			print("Failed to Import")
			return false
		end
	end
	return true
	
end

function Kinect.tryImport(self)
	AllJointPositions = sm.json.open("$CONTENT_DATA/Scripts/Jsonlol.json")
end

function Kinect.client_onFixedUpdate(self)
	
	--print(LoaderID==self.interactable:getId())
	function self.playerSeat()
		return self.interactable:getSingleParent():getSeatCharacter():getId()
	end
	function self.playerPower()
		return self.interactable:getSingleParent():getPower()
	end
	self.idTest, self.why = pcall(self.playerSeat)
	self.idTest2, self.why2 = pcall(self.playerPower)
	if self.interactable:getSingleParent() ~= nil and self.idTest == true then
		self.seat = self.interactable:getSingleParent()
		if self.seat:getSeatCharacter():getId() == sm.localPlayer.getPlayer():getCharacter():getId() then
			if self.isLoaded then
				if self:tryImportData() then
					local table = self.table
					self.joint = table[1]
					if table[2] == 1 then
						self.network:sendToServer('server_writePower', (AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20 + 40))
					elseif table[2] == 0 then
						self.network:sendToServer('server_writePower',(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * -20))
					else
						self.network:sendToServer('server_writePower',(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20))
					end
				end
			end
		end
	elseif self.interactable:getSingleParent() ~= nil and self.idTest2 == true and self.idTest == false then
		if  self.interactable:getSingleParent():getPower() == sm.localPlayer.getPlayer():getCharacter():getId() then
			if self.isLoaded then
				if self:tryImportData() then
					local table = self.table
					self.joint = table[1]
					if table[2] == 1 then
						self.network:sendToServer('server_writePower', (AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20 + 40))
					elseif table[2] == 0 then
						self.network:sendToServer('server_writePower',(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * -20))
					else
						self.network:sendToServer('server_writePower',(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20))
					end
				end
			end
		end
	
	end
		--print(sm.localPlayer.getPlayer():getCharacter():getId())
		--print(self.seat:getSeatCharacter():getId())
end
function Kinect.server_onFixedUpdate(self)
	self.table = self.storage:load()
	self.network:sendToClients('clientTable', self.table)
end
function Kinect.server_writePower(self, data)
	--print("Ee3")
	--print(data)
	self.interactable:setPower(data)
end
function Kinect.client_onInteract(self, character, state)
	local table = self.table
	LoaderID = self.interactable:getId()
	--if state==false then
	if state == true then
		sm.gui.chatMessage( '---------------')
		print('---------------')
		sm.gui.chatMessage( string.format("Joint Name: %s",kinectstuff[table[1]+1]) )
		print(string.format("Joint Name: %s",kinectstuff[table[1]+1]))
		sm.gui.chatMessage( string.format("Joint Type: %s",table[1]) )
		print(string.format("Joint Type: %s",table[1]))
		sm.gui.chatMessage( string.format("XYZ:     	%s",XYZ[table[2]+1]) )
		print(string.format("XYZ: %s",XYZ[table[2]+1]))
		sm.gui.chatMessage( string.format("XYZ Index: %s",table[2]) )
		print(string.format("XYZ Index: %s",table[2]))
		
	end
end
function Kinect.client_canInteract(self,character3)
	local table = self.table
	if table[1] ~= nil and character3 ~= nil then
		sm.gui.setInteractionText(string.format("Joint Name:  %s",kinectstuff[table[1]+1]))
		sm.gui.setInteractionText(string.format("XYZ:  %s",XYZ[table[2]+1]))
	end
    return true
end
function Kinect.server_onCreate(self)
	
	if LoaderID == nil then
		LoaderID = self.interactable:getId()
	end

	if self.storage:load() == nil then
		self.storage:save({ 0, 0 })
	end
	self.isLoaded = true
	self.table = self.storage:load()
	self.network:sendToClients('clientCreate')
	self.network:sendToClients('clientTable', self.table)
end

function Kinect.server_onRefresh( self )
	self.server_onCreate(self)
end
function Kinect.clientCreate(self)
	self.isLoaded = true
end
function Kinect.server_onDestroy(self)
	if LoaderID == self.interactable:getId() then
		LoaderID = nil
	end
end