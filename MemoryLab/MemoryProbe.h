#ifndef MemoryProbe_h
#define MemoryProbe_h

#include <stdint.h>

uint64_t ml_available_memory(void);
uint64_t ml_phys_footprint(void);
uint64_t ml_peak_footprint(void);

#endif
