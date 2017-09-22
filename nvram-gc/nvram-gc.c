/*********************************************************************
 * Filename:      nvram-gc.c
 *                
 * Copyright (C)  2013 Madper Xie.
 * Version:       
 * Author:        madper <bbboson@gmail.com>
 * Created at:    Wed Dec  4 17:35:46 2013
 *                
 * Description:   This module attempts to trigger uefi nvram reclaimation by
 * alloction a huge space. FWIK, reclaimation is a time-consuming event and will
 * mask interrupts(include nmi) on some vendors. If we didn't feed NMI watchdog
 * for a long time during reclimation, it panic. This is a simple case which
 * will test if the default timeout value is long enough for uefi storage
 * reclimation. 
 *                
 ********************************************************************/
#include <linux/efi.h>
#include <linux/kernel.h>
#include <linux/module.h>

static __init int gc_trigger_init(void)
{
	efi_status_t status;
	u64 storage_size, remaining_size, max_size;
	
	status = efi.query_variable_info(EFI_VARIABLE_NON_VOLATILE |
					EFI_VARIABLE_BOOTSERVICE_ACCESS |
					EFI_VARIABLE_RUNTIME_ACCESS,
					&storage_size, &remaining_size, &max_size);
	if (status != EFI_SUCCESS)
		return status;

	printk("remaining_size == %llu\n", remaining_size);
	status = efi_query_variable_store(EFI_VARIABLE_NON_VOLATILE |
					EFI_VARIABLE_BOOTSERVICE_ACCESS |
					EFI_VARIABLE_RUNTIME_ACCESS, remaining_size - 500);
	if (status == EFI_SUCCESS)
		printk("I wonder why this call return success!?!? \n");
	
	return status;
}

static __exit void gc_trigger_exit(void)
{
}

module_init(gc_trigger_init);
module_exit(gc_trigger_exit);

MODULE_LICENSE("GPL");
