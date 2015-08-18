Pumpkin Browser
---------------

A lightweight WebKitGTK+ browser written in Vala.

[![Build Status](https://semaphoreci.com/api/v1/projects/b97efd4f-36f1-4f28-8ef7-520f9ea774d2/514614/badge.svg)](https://semaphoreci.com/dannote/pumpkin-browser)

![Screenshot](screenshot.png?raw=true)      

Building
========

Ubuntu
```
sudo apt-get install gnome-common libglib2.0-dev libgtk-3-dev \
  libvala-0.26-dev valac-0.26 gobject-introspection libwebkit2gtk-4.0-dev \
  libnotify-dev libjson-glib-dev libsoup2.4-dev

mkdir build
cd build
cmake ..
make
```