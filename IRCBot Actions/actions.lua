-- IRCBot lua script
-- actions


-- The main	function --
function main(data, args, irc)
	print('Running main function');

	actions = irc:getActions()
	actions_string = 'Actions: hi, ping, shutdown, version'
	irc:sendMessage_to_(actions_string,data[5])
	
	print('end')	
end
