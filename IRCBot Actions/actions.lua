-- IRCBot lua script
-- ping

-- Import the base frameworks
LuaCocoa.import("Foundation")


-- The main	function --
function main(data, args, irc)
	print('Running main function');

	--actions = irc:getActionsList()
	actions_string = NSString:alloc():initWithUTF8String('IRCBot Actions: hi, ping, shutdown')	
	irc:sendMessage_to_(actions_string,data[5])
	
	print('end')	
end
