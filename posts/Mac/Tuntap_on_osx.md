date: 2013-12-11
title: Enable tunnel device support on OSX

Ever since I've bought my Macbook Pro, shit things never stop happening.

Recently I was working on [hans](https://github.com/supermartian/hans), which requires tun/tap support on the system. It is said to be supporting OSX, however after building from the source and run it as client on my Mavericks, it goes "_Unable to open tunnel device, no such device._:". 

On Linux, the tun/tap device driver is integrated, so I thought that OSX had it integrated too, and this error prompt could be something wrong *EXCEPT* the tun/tap device driver's problem. After googling the error output for a long time without any useful information, it turns out this can only be the problem of tun/tap device driver.

Just a simple command solved my problem:

    brew install tuntap

After a reboot, I can finally use hans on my Mac.

#### External links

1. [hans the original](http://code.gerade.org/hans/)
2. [tuntaposx](http://tuntaposx.sourceforge.net)
