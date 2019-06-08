#include <avr/io.h>
#include <util/delay.h>

int
main(void)
{
    // PB3 as output
    DDRB = (1 << 3);

    while (1) {
        PORTB = (1 << 3);
        _delay_ms(1000);
        PORTB = 0;
        _delay_ms(1000);
    }

    return 0;
}
