```
// -------------------------- CRT WINDOWS TERMINAL SHADER --------------------------
//
// ╔═╗╦═╗╔╦╗  ╦ ╦╦╔╗╔╔╦╗╔═╗╦ ╦╔═╗  ╔╦╗╔═╗╦═╗╔╦╗╦╔╗╔╔═╗╦   ╔═╗╦ ╦╔═╗╔╦╗╔═╗╦═╗
// ║  ╠╦╝ ║───║║║║║║║ ║║║ ║║║║╚═╗───║ ║╣ ╠╦╝║║║║║║║╠═╣║───╚═╗╠═╣╠═╣ ║║║╣ ╠╦╝
// ╚═╝╩╚═ ╩   ╚╩╝╩╝╚╝═╩╝╚═╝╚╩╝╚═╝   ╩ ╚═╝╩╚═╩ ╩╩╝╚╝╩ ╩╩═╝ ╚═╝╩ ╩╩ ╩═╩╝╚═╝╩╚═
//
// A CRT shader for the Windows Terminal.
//
// Trying to balance looks and performance.
// The film grain & flicker effects are very expensive,
// they require constant redraw of the terminal.
//
// A lot of this is probably not the best, as it is my first time writing HLSL.
// Also I am not that great at math, and this was done under 4 hours.
//
// Originally based on "CRT Shader Effect for Windows Terminal" by Lorgar Horusov.
//
// @author Luna Mira Lage
// @version 1.0
// @see https://github.com/Lorgar-Horusov/Retro-Windows-Terminal
// @see https://github.com/microsoft/terminal/blob/main/samples/PixelShaders
// ---------------------------------------------------------------------------------
```

<img width="2470" height="990" alt="image" src="https://github.com/user-attachments/assets/3b260c72-e36d-4849-aa65-d1ee4f5b5f69" />
