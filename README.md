# Odin FWS

This is a very simple file system watcher for Odin, using windows api (IOCP)

This is a not a complete solution for File Watching, just a simple layer on top of `ReadDirectoryChangesW` + `IOCP`. So it will only accept directories to watch. 
Making it capable of watching only files, or to better control when events occur(see the issue below), will be left to the user to develop, since there are tradeoffs that i don´t want this lib to made.


## Known issue related to windows API
	
The function `ReadDirectoryChangesW()` will dispatch double `MODIFIED` events, and its by "design". (you can read more [here](https://stackoverflow.com/questions/14036449/c-winapi-readdirectorychangesw-receiving-double-notifications) )

This project will not solve this problem, since its intention is to be a very simple layer on top of the related functions of the windows api.
