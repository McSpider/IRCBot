-- IRCBot lua script
-- ping

-- Import the base frameworks
LuaCocoa.import("Foundation")


-- The main	function --
function main(data, args, irc)
	print('Running main function');

	msg = 'Bye: Don\'t forget to feed the goldfish.'
	
	shutdown_string = NSString:alloc():initWithUTF8String(msg)	
	irc:dissconectWithMessage(shutdown_string)
	
	print('end')	
end
