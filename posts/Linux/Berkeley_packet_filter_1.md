date: 2013-04-01
title: Berkeley Packet Filter - Intro

### Introduction

BPF(Berkeley Packet Filter) provides an elegant and flexible interface for filtering packets on data link layer. The filter is in the very early stage (Network driver level) of the packet-processing chain, which may avoids unnecessary data copies during the process in the later stages. Thus it makes it possible to process large amount of packets while it costs fewer CPU and memory resources than filter the packets in user-space.

BPF's functionality is implemented as an interpreter for a machine language for the BPF virtual machine. Using the BPF's assembly language, programmers are able to perform quite fancy filtering logics to the packets.

<center>
![BPF implementation in Linux](/images/lpf.jpg "BPF implementation in Linux")
The BPF in Linux (Linux packet filter, aka LPF), it is implemented right on network driver level.
</center>

### Take a glance

We can take a glance at BPF through a celebrated tool, tcpdump. A user-mode interpreter for BPF's assembly language is provided by the libpcap/WinPcap. Therefore it can do the BPF things on the systems that don't have BPF implemented in kernel. (Of course it takes advantages of kernel on those systems which have BPF implemented).

Using *-d* *-dd* *-ddd* in tcpdump we can see what our filter parameters will become after they are translated into BPF's assembly language. The man page illustrates the details of these 3 options.

    -d     Dump the compiled packet-matching code in a human readable form to standard output and stop.
    -dd    Dump packet-matching code as a C program fragment.
    -ddd   Dump packet-matching code as decimal numbers (preceded with a count).,

So let's take a simple example of BPF assembly. We want to have all the IP packets on wlan0 and using -d to see the BPF code.

    Ginger:/home/martian # tcpdump -i wlan0 'ip' -d
    (000) ldh      [12]
    (001) jeq      #0x800           jt 2    jf 3
    (002) ret      #65535
    (003) ret      #0

The memory base of the this piece code is the start of a packet(From the Layer 2). So the first line means *"Loads the data in offset 12 to accumulator"*, which is the payload type segment of the Ethernet frame.

0x0800 is the type of IP, therefore the second line indicates an comparation between 0x0800 and the value stored in accumulator. If true, jump to 2, or to 3 if they are not equal.

The third line terminates the filter and return at most 65535 bytes of the packet, which means the packet is accepted and will be transmited to the userspace.

The forth line also terminates the filter, but the packet will be ignored and the userspace will not receive it.

After all these, we have an IP packet in the end.

#### External links

1. [1993 USENIX paper that describes BPF](http://www.tcpdump.org/papers/bpf-usenix93.pdf)
2. [The Linux Socket Filter: Sniffing Bytes over the Network](http://www.linuxjournal.com/article/4659?page=0,0)
3. [netsniff-ng](http://netsniff-ng.org/)
4. [A JIT for packet filters](http://lwn.net/Articles/437981/)
5. [Nftables: a new packet filtering engine](http://lwn.net/Articles/324989/)
