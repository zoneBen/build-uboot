#!/bin/bash
# tools/make_fit_atf.sh
# Optional script for creating FIT image with ARM Trusted Firmware

# This is a template script for creating a FIT image that includes
# ARM Trusted Firmware (BL31), U-Boot, and device tree
# It's referenced by CONFIG_SPL_FIT_GENERATOR

set -e

usage() {
    echo "Usage: $0 <dtb_file> <output_file>"
    exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

DTB_FILE=$1
OUTPUT_FILE=$2

# Create a temporary .its file
cat > temp.its << __EOF__
/dts-v1/;

/ {
	description = "U-Boot FIT Image for RK3288";
	#address-cells = <1>;

	images {
		uboot {
			description = "U-Boot";
			data = /incbin/("u-boot-dtb.bin");
			type = "standalone";
			arch = "arm";
			os = "u-boot";
			compression = "none";
			load = <0x01000000>;
			entry = <0x01000000>;
		};
		
		fdt {
			description = "rk3288-cmt-cube";
			data = /incbin/("$DTB_FILE");
			type = "flat_dt";
			arch = "arm";
			compression = "none";
		};
	};

	configurations {
		default = "config@1";
		config@1 {
			description = "Boot configuration";
			fdt = "fdt";
			kernel = "uboot";
		};
	};
};
__EOF__

# Create the FIT image
mkimage -f temp.its "$OUTPUT_FILE"

# Clean up
rm -f temp.its

echo "FIT image created: $OUTPUT_FILE"