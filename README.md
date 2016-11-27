# VHDL Bubble trouble
This is an end project for my college subject called "Digitalno načrtovanje". It represents famous online game "Bubble trouble". But this project is created in VHDL language instead of Flash or Javascript. VHDL is not programming language. It is (as initials say) hardware description language. For those that don't know this language - it is extremly hard to program in it.

## Bubble trouble game 
The goal of Bubble Trouble game is to destroy all balls or balloons (whatever you wanna call it). If a ball by any chance hits you - YOU LOSE. But if you destroy all balls - YOU WIN. There are just few limitations. You can only shoot vertically and have to wait until bullet reaches top corner before you can shoot again. Every time ball is destroyed, 2 new balls are created. Each new ball is smaller than it's predecesor.

## Support
I must warn you that this project was made for specific board. It works only with Digilent Nexys 2 Spartan 3E board, but with a few minor changes it can also work with Digilent Nexys 4 board. Game is displayed via VGA protocol and only works in 640x480 resolution.

## Design components
Program is made with some very common components like: RAM, Negative edge founder, Prescaler, Timer, Counter, PS2 Controller, Shift register, VSYNC and HSYNC (for VGA display).
There are also components I programmed, components like: Player, Rope, Ball_Big, Ball_Medium, Ball_Small, Ball_XSmall and Game.

## Screenshot
![alt tag](https://raw.githubusercontent.com/mrLukas/VHDL-Bubble-trouble/master/Game.jpg)
