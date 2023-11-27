# Overview

This program is a networked version of a simple arena shooter that I replaced the ai enemies with other players

I created this program to get a better understanding of networking as well as working within the 3D aspects of Godot

[Software Demo Video](https://youtu.be/L12ao-14FXk)

# Network Communication

The game uses a simple client/server architecture and uses UDP for communicating data.

The networking script within the world and player files handles player connection, disconnection, creating seperate players, as well as updating all of those players variables such as position, rotation, etc.

# Development Environment

This game was created within Godot using GDscript as its programming language as well as ENet libraries for simpler networking

# Useful Websites

* [Godot Documentation](https://docs.godotengine.org/en/stable/index.html)
* [Multiplayer Documentation](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
* [ENet library page](http://enet.bespin.org/usergroup0.html)

# Future Work

* Add more player movement options
* Have items that spawn on the ground for players to pick up
* Set up non local-host server options or possibly port-forwarding
