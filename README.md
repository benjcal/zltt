## ZLTT 

This is a simple toy project to create a simple TUI (Text User Interface). Think of emacs TUI but you don't need 10 years to learn it! 😅

Programs for `zltt` are written in Lua and `zltt` uses Zig and SDL to render a GUI.

The Lua API is extremly simple but very versatile. Look at `examples/` for example functionality.

### API

`putMainText(text)`

This function prints `text` to the main screen


`putSubText(text)`

This function prints `text` to the bottom line of the screen


`handleInputEvent(key)`

This function is called when on a KEYDOWN event. The value of `key` is the ascii integer of the charater.
To recover the character in lua use `string.char(key)`

