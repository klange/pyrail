# PyRail - A rail system manager for Minecraft

PyRail uses ComputerCraft and Railcraft to manage to an automated network of trains and train stations using a Python master server running in the real world.

Stations communicate with the server via a simple HTTP API running on a ComputerCraft computer which is attached to detectors and boarding rails. These computers can also optionally be attached to display boards.

The end result is a fully automated system, with support for multiple trains, different lines, autodetection of failed trains, and a web frontend for management and train tracking.
