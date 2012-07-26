What Does It Do?
================

JamWiFi allows you to select one or more nearby wireless networks, thereupon presenting a list of clients which are currently active on the network(s). Furthermore, JamWiFi allows you to disconnect clients of your choosing for as long as you wish.

How Does It Work?
=================

Under the hood, JamWiFi uses Apple's CoreWLAN API for channel hopping and network scanning. For a raw packet interface, libpcap provides a good point of abstraction for sending/receiving raw 802.11 frames at the MAC layer. All 802.11 MAC packets include a MAC address source and destination. This allows JamWiFi to determine the stations on a given Access Point.

JamWiFi "kicks off" clients using a disassociation frame. When a client receives a disassociation frame from an Access Point, it will assume that any connection which it had with the AP is no longer active. However, once a client receives a disassociation frame, it may immediately attempt to establish a new session with the AP. To prevent against this, JamWiFi continually sends disassociation frames to every client quite frequently.

Caveats
=======

Some networks include more than one Access Point. Moreover, there may be scenarios in which more than one usable WiFi network is available to a client. In this scenario, even if a client is disassociated from one AP, it may successfully be able to establish a session with another AP. To overcome this, JamWiFi sends disassociation frames to every client from every AP, whether or not that client may be associated with the AP. While this may seem like unnecessary overhead, it is necessary for more complex networks with >1 access point.

I can't wait to ruin my neighbors' networks!
--------------------------------------------

Just a second, there. I am not responsible for any damage you may do to anybody using this tool. This is for experimental and learning purposes only. Please, please, please, think twice before you do something stupid with this. How would you like it if your WiFi never worked because you had a jerk for a neighbor?
