---@diagnostic disable: need-check-nil
Kinectset = class()
Kinectset.maxParentCount = 0
Kinectset.maxChildCount = -1 -- infinite
Kinectset.connectionOutput = sm.interactable.connectionType.power
Kinectset.colorNormal = sm.color.new(0xff00ffff)
Kinectset.colorHighlight = sm.color.new(0xff55ffff)
PlayerID = 0
function Kinectset.client_onInteract(self, character, state)
    
    PlayerID = (character:getId())
    character2 = character
    self.network:sendToServer('setstuff', character2)
    if state == true then
        sm.gui.chatMessage( string.format("Player ID:       %s",PlayerID) )
        sm.gui.chatMessage( string.format("Player Name: %s",character:getPlayer():getName()) )
        print(string.format("Player ID:   %s",PlayerID) )
        print(string.format("Player Name: %s",character:getPlayer():getName()))
        self.client_canInteract()
    end
    
end
function Kinectset.updatetext(self)
    use = sm.gui.getKeyBinding( "Use", true )
    sm.gui.setInteractionText("Set Player",use)
    sm.gui.setInteractionText(character2:getPlayer():getName())
end
function Kinectset.client_canInteract(self,character3)
    if character2 ~= nil and character3 ~= nil then
        use = sm.gui.getKeyBinding( "Use", true )
        sm.gui.setInteractionText("Set Player",use)
        sm.gui.setInteractionText(character2:getPlayer():getName())
    end
    return true
end

function Kinectset.setstuff(self,chare)
    self.network:sendToClients('updatetext', chare)
end
function Kinectset.server_onFixedUpdate(self)
    PlayerID2 = PlayerID
    if PlayerID2 ~= self.interactable:getPower() then

        self.interactable:setPower(PlayerID2)
    end
end
