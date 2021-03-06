ACCLAIM_BOOTLOADER := device/bn/acclaim/prebuilt/boot/flashing_boot_emmc.img
ACCLAIM_SDCARD_BOOTLOADER := device/bn/acclaim/prebuilt/boot/flashing_boot.img
TMP_ZEROS := /tmp/zeros

define make_zeros
  bootloader_size=$$($(call get-file-size,$(1))); \
  zeros_size=$$(((512 * 1024) - bootloader_size)); \
  dd if=/dev/zero of=$(2) bs=1 count=$$((zeros_size))
endef

# this is a copy of the build/core/Makefile target
# $(INSTALLED_BOOTIMAGE_TARGET) renamed to .sdcard
$(INSTALLED_BOOTIMAGE_TARGET).sdcard :  $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Making target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) --output $@

$(INSTALLED_BOOTIMAGE_TARGET): \
		$(INSTALLED_BOOTIMAGE_TARGET).sdcard $(ACCLAIM_BOOTLOADER)
	$(call pretty,"Adding nook specific u-boot for boot.img")
	$(call make_zeros,$(ACCLAIM_BOOTLOADER),$(TMP_ZEROS))
	cp $(ACCLAIM_BOOTLOADER) $@
	cat $(TMP_ZEROS) >> $@
	rm $(TMP_ZEROS)
	cat $@.sdcard >> $@
	$(hide) $(call assert-max-image-size,$@, \
		$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)

# this is a copy of the build/core/Makefile target
# $(INSTALLED_RECOVERYIMAGE_TARGET) renamed to .sdcard
$(INSTALLED_RECOVERYIMAGE_TARGET).sdcard: \
		$(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel)
	@echo ----- Making recovery image ------
	$(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) --output $@
	@echo ----- Made recovery image -------- $@

$(INSTALLED_RECOVERYIMAGE_TARGET): \
		$(INSTALLED_RECOVERYIMAGE_TARGET).sdcard \
		$(ACCLAIM_BOOTLOADER)
	$(call pretty,"Adding nook specific u-boot for recovery.img")
	$(call make_zeros,$(ACCLAIM_BOOTLOADER),$(TMP_ZEROS))
	cp $(ACCLAIM_BOOTLOADER) $@
	cat $(TMP_ZEROS) >> $@
	rm $(TMP_ZEROS)
	cat $@.sdcard >> $@
	$(hide) $(call assert-max-image-size,$@,\
		$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)

