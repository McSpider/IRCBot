--: IRCBot lua script :--
--: version :--


--: The main	function :--
function main(data, args, irc)
	print('Running main function');
	
	version = irc:getVersion()
	
	version_string = 'IRCBot - https://github.com/McSpider/IRCBot'
	irc:sendMessage_to_(version_string,data[5])
	
	version_string = 'Version ' .. version .. ' - Running ' .. _VERSION
	irc:sendMessage_to_(version_string,data[5])
	
	print('end')	
end