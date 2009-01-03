Since I'm vaguely distrustful of my fellow man, I try to take precautions against my data leaking out into the world. One of the more effective ways of protecting my data is to ensure that it's stored on my computer in an encrypted fashion.  If my laptop is stolen, I can rest easily, knowing that no sane person will take the time to brute-force a 256 bit key in order to read my (relatively mundane) email.  I've often tried using OS X's [FileVault][] for exactly this purpose, and equally often abandoned it.  It simply doesn't work for me.  Here, I'll outline where it falls down for me, and the solution I've settled upon.

[FileVault]: http://en.wikipedia.org/wiki/FileVault

FileVault is Inconvenient
-------------------------

The shortcomings of FileVault all really boil down to tradeoffs against convenience.  For example, making regular backups with the tools I prefer becomes a relatively arduous and manual task.  The excellent [SuperDuper][] is quite flakey when used on a currently-logged-in FileVaulted account (and explicitly warns against such a setup in it's documentation), and [TimeMachine][] only backs up your vault when you log out, which makes it much less useful than it would otherwise be.

These problems have a common root cause in FileVault's implementation: it wraps your entire home directory up into an encrypted disk image, and automates the process of mounting it when you log in.  Keeping this disk image open means that it's contents are (probably) constantly changing, which means that the on-disk, encrypted representation of your data can't be relied on to be stable long enough to be copied elsewhere.  This is annoying.

Since I store a good chunk of my transient data in version control on [GitHub][] anyway, TimeMachine isn't stunningly important to me, but SuperDuper is.  Having an instantly bootable backup of my machine is a measure of protection that I don't want to give up, and if I have to regularly log out and run the backup from a non-FileVaulted account, then I'm not going to do it.  I need a solution that retains automation, one that I simply don't need to think about.

[SuperDuper]: http://www.shirt-pocket.com/SuperDuper/SuperDuperDescription.html
[TimeMachine]: http://en.wikipedia.org/wiki/Time_Machine_(Apple_software)
[GitHub]: http://github.com/mikewest/