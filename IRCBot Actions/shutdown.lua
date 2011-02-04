-- IRCBot lua script
-- shutdown


-- The main	function --
function main(data, args, irc)
	print('Running main function');
	
	confirmation_string = 'Shutting down as ordered by: ' .. data[2]
	irc:sendMessage_to_(confirmation_string,data[5])

	shutdown_string = 'Bye: Don\'t forget to feed the goldfish.'
	irc:dissconectWithMessage(shutdown_string)
	
	print('end')
end
