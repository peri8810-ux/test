on run
	set pagePath to POSIX path of (path to resource "MarioTestapp.html")
	do shell script "/usr/bin/open " & quoted form of pagePath
end run
