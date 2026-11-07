// main.cpp

#include <inttypes.h>

#include "memory_map.h"
#include "basic_io.h"

int main()
{

    // initialization
    BasicIO bio(BASIC_IO_BASE_ADDRESS);

    uint8_t led_test_pattern = 0xFF;
    bio.write_leds(led_test_pattern);

    if (led_test_pattern != bio.read_leds())
    {
        while (true)
        {
        }
    }

    uint8_t previous_switches = bio.read_switches();
    bio.write_leds(previous_switches);

    while (1)
    {
        uint8_t current_switches = bio.read_switches();
        if (current_switches != previous_switches)
        {
            bio.write_leds(current_switches);
            previous_switches = current_switches;
        }
    }
}
