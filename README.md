Objective C IRCBot
==================

An IRC Bot written mainly in Objective C.  
Still needs lots of changes to make it functional.  
  
  
###IRCBot Uses:
[AsyncSocket](http://code.google.com/p/cocoaasyncsocket/), to connect to the irc server.  
[EMKeychain](http://extendmac.com/EMKeychain/), to store the login details.  
[RegexKitLite](http://regexkit.sourceforge.net/), to parse the irc messages.  
[BWToolkitFramework](http://www.brandonwalkin.com/bwtoolkit/), for several UI elements.  
  
  
###Current Actions:
shutdown: disconnect the bot.  
version: print the bot version.  
actions: print a list of available actions.  
hi: say hello.  
ping: send a ping, replies with 'Sender: pong'.  

Actions are simple .lua files, with lots of possibilities.  