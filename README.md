hello-elementary
----------------

Quick start elementary OS application. Check [official docs](https://elementary.io/en/docs/code/getting-started) for more about building for elementary OS.


## Prerequisite

elementary SDK

```
$ sudo apt install elementary-sdk
```

[Optional] source code beautifier

```
$ sudo apt install uncrustify
```

## Getting Started

### Terminal

```
$ git clone https://github.com/abiosoft/hello-elementary hello
$ cd hello 
$ sh -c "meson build && cd build && ninja"
$ build/src/com.github.user.hello
```

### Gnome Builder

Open cloned repository directory, or `App Menu > Clone Repository`.

includes:

* vala beautifer (compatible with [vala-lint](https://github.com/elementary/vala-lint))
* default flatpak config (for optional flatpak distribution)


## Screenshot

![screenshot](screenshot.png)
