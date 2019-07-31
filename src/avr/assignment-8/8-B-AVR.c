
#include <avr/io.h>
#include <stdio.h>

int main(void) {
  int a,b,c,d,e,f0,f1,f2,x;
  DDRA = 0xFF;
  DDRC = 0b11100000;

    while(1) {
    x=PINC;
    a=x&0x01;
    b=x&0x02;
    b=b>>1;
    c=x&0x04;
    c=c>>2;
    d=x&0x08;
    d=d>>3;
    e=x&0x10;
    e=e>>4;
    f0=!((a&b) | (b&c) | (c&d) | (d&e));
    f1= (((a&b)&c)&d) | (!(d | e));
    f2= f0 | f1;
    f1=f1<<1;
    f2=f2<<2;
    PORTA=f0 | f1 |f2;
  }
}
