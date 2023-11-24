For *"fun"*, I have compiled a list of every single problem I consider shouldn't have happened that I've encountered anyways, going through Steam's configuration files.

I put them in order, from ***most annoying*** to *least annoying*.

This is meant to warn people to not create code that may cross these issues.

___

# Problems

## Linux games don't get removed from *compat.vdf* when going back from their Windows version.

### Conclusion

We have no way from Steam's configuration files to know if a game that ever had a Windows version installed now has its Linux version installed.

I looked everywhere I could for an alternative configuration file (or a file that could be useful through another method), but came empty-handed.

### Workaround

We check for Linux executables or shell scripts in every Windows game's root directory.

We previously used in a loop

```lua
os.execute("file "..location.."/"..file.." | grep -e 'Linux' -e 'shell' &> /dev/null")
```

to detect those.

However, ironically, this method led us into another problem later on, which required us to scrap the os.execute approach.

## *libraryfolders.vdf* doesn't get immediately updated upon game installation/uninstallation.

### Conclusion

This problem effectively makes it completely unreliable (and thus useless) to gather the game IDs stored inside it.

### Workaround

As a workaround, we look in the library folders for *appmanifest_ID.acf* files, and use them to guess the installed game IDs and gather the data.

## Steam can get stuck trying to start a game when using *os.execute* many times.

### Workaround

Use os.execute as little as possible if launching a game.
