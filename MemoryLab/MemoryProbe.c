#include "MemoryProbe.h"
#include <os/proc.h>
#include <mach/mach.h>

uint64_t ml_available_memory(void) {
    return (uint64_t)os_proc_available_memory();
}

static int ml_task_vm_info(task_vm_info_data_t *info, mach_msg_type_number_t *count) {
    *count = TASK_VM_INFO_COUNT;
    kern_return_t kr = task_info(
        mach_task_self(),
        TASK_VM_INFO,
        (task_info_t)info,
        count
    );
    return kr == KERN_SUCCESS ? 0 : -1;
}

uint64_t ml_phys_footprint(void) {
    task_vm_info_data_t info = {0};
    mach_msg_type_number_t count = 0;

    if (ml_task_vm_info(&info, &count) != 0) {
        return 0;
    }

    return (uint64_t)info.phys_footprint;
}

uint64_t ml_peak_footprint(void) {
    task_vm_info_data_t info = {0};
    mach_msg_type_number_t count = 0;

    if (ml_task_vm_info(&info, &count) != 0) {
        return 0;
    }

#if defined(TASK_VM_INFO_REV3_COUNT)
    if (count >= TASK_VM_INFO_REV3_COUNT && info.ledger_phys_footprint_peak > 0) {
        return (uint64_t)info.ledger_phys_footprint_peak;
    }
#endif

    return (uint64_t)info.phys_footprint;
}
