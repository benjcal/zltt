## ZLTT 

This is a simple toy project to create a simple TUI (Text User Interface). Think of emacs TUI but you don't need 10 years to learn it! 😅

Programs for `zltt` are written in Lua and `zltt` uses Zig and SDL to render a GUI.

The Lua API is extremly simple but very versatile. Look at `lua/examples/` for example functionality.

### Requirements

Zig
SDL2
LuaJIT

### Instructions 

To build run `zig build`

To run an example do `./zig-out/bin/zltt lua/examples/todo/init.lua`

## Examples

https://user-images.githubusercontent.com/2781653/123039629-58ef2980-d3a7-11eb-92ca-4f71f105ebd9.mp4

https://user-images.githubusercontent.com/2781653/123039640-5db3dd80-d3a7-11eb-9e17-2bfebf9ae951.mp4


### API

`putMainText(text)`

This function prints `text` to the main screen


`putSubText(text)`

This function prints `text` to the bottom line of the screen


`handleInputEvent(key)`

This function is called when on a KEYDOWN event. The value of `key` is the ascii integer of the charater.
To recover the character in lua use `string.char(key)`

