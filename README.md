# Odin FWS

This is a very simple file system watcher for Odin, using windows api (IOCP)

## TODO:

- Wait `until arrive` events as alternative
- More control over windows api buffer memory size
- Watch single files instead of directories

## Known issue related to windows API
	
The function `ReadDirectoryChangesW()` will dispatch double `MODIFIED` events, and its by "design". (you can read more [here](https://stackoverflow.com/questions/14036449/c-winapi-readdirectorychangesw-receiving-double-notifications) )

This project will not solve this problem, since its intention is to be a very simple layer on top of the related functions of the windows api.