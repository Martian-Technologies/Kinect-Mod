---@diagnostic disable: need-check-nil
Kinect = class()
Kinect.maxParentCount = 1 
Kinect.maxChildCount = -1 -- infinite
Kinect.connectionInput = sm.interactable.connectionType.seated
Kinect.connectionOutput = sm.interactable.connectionType.power
Kinect.colorNormal = sm.color.new(0xffff00ff)
Kinect.colorHighlight = sm.color.new(0xffff55ff)
LoaderID = nil

function Kinect.server_onMelee(self)
	print("xyz index")
	sm.gui.chatMessage( "xyz index" )
	local table = self.storage:load()
	table[2] = table[2] + 1
	if table[2] > 2 then
		table[2] = 0
	end
	self.storage:save(table)
	self.table = self.storage:load()
	print(table[2])
	sm.gui.chatMessage( tostring(table[2] ))
	self.network:sendToClients('clientTable', self.table)
end

function Kinect.server_onProjectile(self)
	print("JOINT TYPE")
	sm.gui.chatMessage( "JOINT TYPE" )
	local table = self.storage:load()
	table[1] = table[1] + 1
	if table[1] > 24 then
		table[1] = 0
	end
	self.storage:save(table)
	self.table = self.storage:load()
	print(table[1])
	sm.gui.chatMessage( tostring(table[1] ))
	self.network:sendToClients('clientTable', self.table)
end
function Kinect.clientTable(self, tbl)
	self.table = tbl
end

function Kinect.tryImportData(self)
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
	function self.playerSeat()
		return self.interactable:getSingleParent():getSeatCharacter():getId()
	end

	self.idTest, self.why = pcall(self.playerSeat)
	--print(self.idTest,self.why)
	if self.interactable:getSingleParent() ~= nil and self.idTest == true then
		self.seat = self.interactable:getSingleParent()
		--print(sm.localPlayer.getPlayer():getCharacter():getId())
		--print(self.seat:getSeatCharacter():getId())
		if self.seat:getSeatCharacter():getId() == sm.localPlayer.getPlayer():getCharacter():getId() then
			
			if self.isLoaded then
				--print("E")
				if self:tryImportData() then
					local table = self.table
					self.joint = table[1]
					if table[2] == 1 then
						--print((AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20 + 40))
						self.network:sendToServer('server_writePower', (AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20 + 40))
						
						--self.interactable:setPower(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20 + 40)
					elseif table[2] == 0 then
						self.network:sendToServer('server_writePower',(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * -20))
						--self.interactable:setPower(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * -20)
					else
						self.network:sendToServer('server_writePower',(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20))
						--self.interactable:setPower(AllJointPositions[table[1] + 1][table[2] + 1] * 4 * 20)
					end
				end
			end
		end
	end
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
		print('---------------')
		sm.gui.chatMessage( '---------------')
		print("JOINT TYPE")
		sm.gui.chatMessage( "JOINT TYPE" )
		print(table[1])
		sm.gui.chatMessage( tostring(table[1]) )
		print("xyz index")
		sm.gui.chatMessage( "xyz index" )
		print(table[2])
		sm.gui.chatMessage( tostring(table[2]))
	--end
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