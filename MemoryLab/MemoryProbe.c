#include "MemoryProbe.h"
#include <os/proc.h>
#include <libproc.h>
#include <sys/resource.h>
#include <unistd.h>

uint64_t ml_available_memory(void) {
    return (uint64_t)os_proc_available_memory();
}

static int ml_rusage(rusage_info_current *info) {
    return proc_pid_rusage(getpid(), RUSAGE_INFO_CURRENT, (rusage_info_t *)info);
}

uint64_t ml_phys_footprint(void) {
    rusage_info_current info = {0};
    return ml_rusage(&info) == 0 ? info.ri_phys_footprint : 0;
}

uint64_t ml_peak_footprint(void) {
    rusage_info_current info = {0};
    return ml_rusage(&info) == 0 ? info.ri_lifetime_max_phys_footprint : 0;
}
