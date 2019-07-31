#include <avr/io.h>
#include <stdbool.h>


int single_rotator (int orientation, int LED) {
  if (orientation == -1) {
    if (LED == 0x80)
      return 0x01;
    else
      return LED << 1;  //shift left
  }else {
    if (LED == 0x01)
      return 0x80;
    else
      return LED >> 1;  //shift right
  }
}

int rotating_operator (int orientation, int repeats, int LED) {
  for (int i=0; i < repeats; i++) {
    LED = single_rotator(orientation, LED);
  }

  return LED;
}


int main(void) {
  DDRB = 0xFF;  // Set PORTB as output
  DDRD = 0x00;    // Set PORTD as input
  int LED = 0x01; // Set initial state to 1

  bool buttons_pressed[5];

  for (int i = 0; i < 5; i++) {
    buttons_pressed[i] = false;
  }

  while(1) {
    PORTB = LED;

    // Macro bit_is_set;
    // Test whether bit bit in IO register sfr is set.
    // This will return a 0 if the bit is clear,
    // and non-zero if the bit is set.
    if (bit_is_set(PIND, PIND0)) {
      buttons_pressed[0] = true;
    }

    if (bit_is_set(PIND, PIND1)) {
      buttons_pressed[1] = true;
    }

    if (bit_is_set(PIND,PIND2)) {
      buttons_pressed[2] = true;
    }

    if (bit_is_set(PIND,PIND3)) {
      buttons_pressed[3] = true;
    }

    if (bit_is_set(PIND,PIND4)) {
      buttons_pressed[4] = true;
    }

    // Macro bit_is_clear;
    // Test whether bit bit in IO register sfr is clear.
    // This will return non-zero if the bit is clear,
    // and a 0 if the bit is set.
    if (bit_is_clear(PIND,PIND0) && (buttons_pressed[0] == true)) {
      // SW0 sets the LED one place left
      LED = rotating_operator(-1, 1, LED);
      buttons_pressed[0] = false;
    }

    if (bit_is_clear(PIND,PIND1) && (buttons_pressed[1] == true)) {
      // SW1 sets the LED one place right
      LED = rotating_operator(1, 1, LED);
      buttons_pressed[1] = false;
    }

    if (bit_is_clear(PIND,PIND2) && (buttons_pressed[2] == true)) {
      // SW2 sets the LED two places left
      LED = rotating_operator(-1, 2, LED);
      buttons_pressed[2] = false;
    }

    if (bit_is_clear(PIND,PIND3) && (buttons_pressed[3] == true)) {
      // SW3 sets the LED two places right
      LED = rotating_operator(1, 2, LED);
      buttons_pressed[3] = false;
    }

    if (bit_is_clear(PIND,PIND4) && (buttons_pressed[4] == true)) {
      // SW4 sets the 1st LED
      LED = 0x01;
      buttons_pressed[4] = false;
    }
  }
}
