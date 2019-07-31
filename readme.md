<h1 align="center">
  Microcomputer Assembly
</h1>

<h4 align="center">
  Microcomputer programs in 8085, 8086 & AVR assembly
</h4>

## Description

The repository is home to all 9 Lab Assignments of the 2017 Microcomputers Lab course @ ECE NTUA.

8086/85 programs have been coded, debugged and tested using the appropriate 8086/85 emulators. AVR programs have been coded, debugged and tested on actual AVR Microcomputers.

## Contents

- [Description](#description)
- [8085 Assembly](#8085-assembly)
- [8086 Assembly](#8086-assembly)
- [AVR Assembly](#avr-assembly)
- [Links](#links)
- [Team](#team)
- [License](#license)

## 8085 Assembly

### Assignment 1

#### 1A - LED Binary Milliseconds Timer

Simple milliseconds timer, presenting time in binary form using LED lights as output.

#### 1B - LED Lighting Manipulator

Manipulating the on/off time interval of LED lights through switches.

#### 1C - LED Interrupts Counter

Simple interrupts counter, MSB switch dependent, using LED lights as output.

### Assignment 2

#### 2A - LED Simulated Moving Train

A plain LED train simulator, where train direction is interrupt dependent.

#### 2B - Button Code Reader

Displaying the ASCII value of a pressed key, using 7 segment displays.

#### 2C - Interactive Binary to Decimal Conversion

Taking switch-based binary input, and displaying its corresponding decimal value, using 7 segment displays.

### Assignment 3

#### 3A - Message Manipulator

On demand clockwise or counterclockwise rolling of a string message, printed on 7 segment displays.

## 8086 Assembly

### Assignment 4

#### 4A - Binary Fractions to Decimal

Converting keyboard originated 9-bit, 2's complement, binary fractions to decimal numbers, using 7 segment displays for visual feedback.

#### 4B - Hexadecimal to Decimal

Simple converter of a 3-digit hexadecimal number, to its corresponding decimal value, using 7 segment displays for visual feedback.

#### 4C - String Characters Sorting

Sorting by character type, a user defined input of a 16 characters long string, consisted only of numbers, spaces, capital & lower case letters.

### Assignment 5

#### 5A - File Manipulation

Reading the content of a text file, rotating it clockwise, by a user given amount of character slots and finally storing the outcome to a new text file.

## AVR Assembly

### Assignment 6

#### 6A - Running LED

A sequentially moving LED light between the PA0-PA7 LED ports.

#### 6B - Switches Dependent LED Lighting Manipulator

Setting the LEDs on/off time interval using the `I = x * 100 msec` formula, where `I` is the total time LEDs are switched on/off and `x` the hexadecimal value provided by the user, through the PB0-PB3 dip switches.

#### 6C - Interactive LED Navigation

A simple C program, allowing the user to navigate clockwise or counterclockwise any switched on LED light, pressing the appropriate keys, by one or two LED slots at a time.

### Assignment 7

#### 7A - Mono Interrupts Counter

A simple, PD0 dip switch dependent, interrupts counting program, displaying the binary outcome through the PA7-PA0 LED lights.

#### 7B - Dual Interrupts Counter

An extension to the Mono Interrupts Counter, serving also the INT1 interrupts, as well as displaying through the 4 LSB PORTC LEDs the binary number created using the PORTB dip switches.

#### 7C - Automated Room Lighting

By pressing the appropriate push buttons, the user is able to set the room lighting on or off using different time intervals.

### Assignment 8

#### 8A - IC Simulator

A hypothetical integrated circuit program, where OR, AND and XOR logic gates are simulated using dip switches as logical input and LEDs as logical output.

#### 8B - Boolean Functions

Simulating the following logic functions using dip switches as input and LEDs as output.

```
F0 = (AB + BC + CD + DΕ)’ , F1 = ABCD + D'E', F2 = F0 + F1
```

#### 8C - Electronic Lock

The user through the keypad, types a sequence of numbers and letter, and in the case that the given input matches his predefined password, the LEDs start lighting on/off, thus indicating that there was a correct matching.

### Assignment 9

#### 9A - Keypad Mirror

Displaying the last pressed key to the LCD screen.

#### 9B - Alarm Simulator

Setting a simulated alarm on, whenever the user types, within a 4 seconds time span, an incorrect password. In addition, LEDs are switching constantly on/off and an appropriate message is displayed to the LCD screen. Defusing the alarm is only possible by typing the correct, user predefined, password.

#### 9C - Binary to Decimal

Converting a binary number to decimal and then displaying its decimal value to the LCD screen.

#### 9D - Digital Stopwatch

By constantly pressing the PA0 key the user sets on the stopwatch, which can count up to one hour. The LCD screen is always displaying the time running, and the user is able to stop and resume the stopwatch on demand, as well as resetting it.

## Links

- [AVR Studio](http://www.atmel.com/tools/ATMELSTUDIO.aspx)

## Team

- [Klaus Sinani](https://github.com/klaussinani)

## License

[MIT](https://github.com/klaussinani/microcomputer-assembly/blob/master/license.md)
