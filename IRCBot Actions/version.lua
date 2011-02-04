-- IRCBot lua script
-- version


-- The main	function --
function main(data, args, irc)
	print('Running main function');
	
	--version = irc:getVersion()
	version = 'Version 0.8 Beta'
	
	version_string = 'IRCBot - ' .. version .. ' - https://github.com/McSpider/IRCBot'
	irc:sendMessage_to_(version_string,data[5])
	
	version_string = 'Running Lua 5.1.4'
	irc:sendMessage_to_(version_string,data[5])
	
	print('end')	
end