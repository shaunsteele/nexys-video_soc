// basic_io.cpp

#include "io_macros.h"
#include "basic_io.h"

BasicIO::BasicIO(uint32_t base_address)
{
    base_address_ = base_address;
}

BasicIO::~BasicIO() {}

void BasicIO::write_leds(uint8_t led_pattern)
{
    IO_WRITE(base_address_, LedsOffset, led_pattern);
}

uint8_t BasicIO::read_leds()
{
    return IO_READ(base_address_, LedsOffset) & 0xFF;
}

uint8_t BasicIO::read_switches()
{
    return IO_READ(base_address_, SwitchesOffset) & 0xFF;
}

uint8_t BasicIO::read_buttons()
{
    return IO_READ(base_address_, ButtonsOffset) & 0xFF;
}
