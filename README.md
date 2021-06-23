## ZLTT 

This is a simple toy project to create a simple TUI (Text User Interface) for a smart kitchen.

SDL is used to render the GUI, Zig is used as glue language to interface with the C APIs, and Lua to operate the the app.

The Lua API is extremly simple but very versatile. Look at `examples/` for example functionality.

### API

`putMainText(text)`

This function prints `text` to the main screen


`putSubText(text)`

This function prints `text` to the bottom line of the screen


`handleInputEvent(key)`

This function is called when on a KEYDOWN event. The value of `key` is the ascii integer of the charater.
To recover the character in lua use `string.char(key)`

