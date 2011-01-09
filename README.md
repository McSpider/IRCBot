Objective C IRCBot
==================

An IRC Bot written mainly in Objective C.  
Still needs lots of changes to make it functional but I'm getting there.  
  
  
###IRCBot Uses:
[AsyncSocket](http://code.google.com/p/cocoaasyncsocket/), to connect to the irc server.  
[EMKeychain](http://extendmac.com/EMKeychain/), to store the login details.  
[RegexKitLite](http://regexkit.sourceforge.net/), to parse the irc messages.  
[BWToolkitFramework](http://www.brandonwalkin.com/bwtoolkit/), for several UI elements.  


###Current Commands:
shutdown: disconnect the bot.
auth: check your authentication status.
version: print the bot version.
allow: allow a hostmask to use the restricted functions.
block: block a hostmask from using all functions.
hi: say hello.