--: IRCBot lua script :--
--: version :--


--: The main	function :--
function main(data, args, irc)
	print('Running main function')
	
	irc:joinRoom('##mcspider1')
		
	actions = irc:getActions()
	rooms = irc:getRooms()
	triggers = irc:getTriggers()
	nickname = irc:getNickname()
	version = irc:getVersion()
	
	print('Actions: ' .. actions)
	print('Rooms: ' .. rooms)
	print('Triggers: ' .. triggers)
	print('Nickname: ' .. nickname)
	print('Version: ' .. version)
	
	--: Messages
	
	irc:sendMessage_to_('This is a message','##mcspider')
	irc:sendNotice_to_('This is a notice','##mcspider')
	irc:sendActionMessage_to_('This is a action message','##mcspider')
	
	--irc:sendMessage_to_(actions,'##mcspider')
	--irc:sendMessage_to_(rooms,'##mcspider')
	--irc:sendMessage_to_(triggers,'##mcspider')
	--irc:sendMessage_to_(nickname,'##mcspider')
	--irc:sendMessage_to_(version,'##mcspider')

	--: Hostmasks
	
	--irc:addHostmask_block_('Foo@Bar.com',true)
	--irc:removeHostmask()
	--irc:blockHostmask()
	--irc:unblockHostmask()
	--irc:checkAuthFor('Foo@Bar.com')
	
	irc:partRoom('##mcspider1')
	
	print('end')	
end