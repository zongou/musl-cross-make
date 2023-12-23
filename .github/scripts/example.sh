#!/bin/sh

SCRIPT_DIR="$(dirname $0)"

cat <<-EOF >config.mak
	GCC_VER = 13.2.0
	BINUTILS_VER = 2.41
	MUSL_VER = 1.2.4
	GMP_VER = 6.3.0
	MPC_VER = 1.3.1
	MPFR_VER = 4.2.1
	ISL_VER = 0.26
	LINUX_VER = 6.6.8

	DL_CMD = curl -C - -L -o
	STAT = -static --static
	FLAG = -g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels -Wno-error

	COMMON_CONFIG += CFLAGS="\${FLAG} \${STAT}" CXXFLAGS="\${FLAG} \${STAT}" FFLAGS="\${FLAG} \${STAT}" LDFLAGS="-s \${STAT} \${STAT}"

	BINUTILS_CONFIG += --enable-gold=yes
	BINUTILS_CONFIG += --disable-gprofng
	GCC_CONFIG += --enable-default-pie --enable-static-pie --disable-cet
EOF

"${SCRIPT_DIR}/build-toolchain.sh" --target=aarch64-linux-musl --cross