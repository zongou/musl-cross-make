#!/bin/sh
set -eu

if test $# -gt 0; then
	while test $# -gt 0; do
		case "$1" in
		--target=*)
			TARGET=$(echo "$1" | sed 's/^--target=//')
			shift
			;;
		--cross | --native)
			TAG=$(echo "$1" | sed 's/^--//')
			shift
			;;
		*)
			echo wrong opt "$*"
			exit 1
			;;
		esac
	done
fi

## Clean up
rm -rf "${TARGET}-${TAG}"

OUTPUT="${PWD}/${TARGET}-${TAG}"

## Create dir to store logs
LOG_DIR=${PWD}/build-log
mkdir -p "${LOG_DIR}"
LOG_FILE=${LOG_DIR}/${TARGET}-${TAG}-$(date +%Y%m%d-%H%M%S).log

case "${TAG}" in
cross)
	make install \
		TARGET="${TARGET}" OUTPUT="${OUTPUT}" \
		-j"$(nproc)" 2>&1 | tee "${LOG_FILE}"
	rm -rf "${PWD}/build/local/${TARGET}"
	;;
native)
	export PATH="${PWD}/${TARGET}-cross/bin":"${PATH}"
	make install \
		HOST="${TARGET}" TARGET="${TARGET}" OUTPUT="${OUTPUT}" \
		-j"$(nproc)" 2>&1 | tee "${LOG_FILE}"
	rm -rf "${PWD}/build/${TARGET}"
	;;
esac

## Symlink usr if not exists
if ! test -e "${OUTPUT}/usr"; then
	(cd "${OUTPUT}" && ln -s . usr)
fi

# ## Convert hardlink to symlink in $PWD
# ## [query]
# h2s() {
# 	samefile_source="$1"
# 	(
# 		find . -samefile "${samefile_source}" | while IFS= read -r samefile; do
# 			if ! test "$(realpath "${samefile_source}")" = "$(realpath "${samefile}")"; then
# 				ln -snf "${samefile_source}" "${samefile}"
# 			fi
# 		done
# 	)
# }

# ## h2s in ${OUTPUT}/${TARGET}/bin
# (cd "${OUTPUT}/${TARGET}/bin" && h2s ld.bfd)

# ## h2s in ${OUTPUT}/bin
# (
# 	cd "${OUTPUT}/bin" || exit 1
# 	find "../${TARGET}/bin" -type f | while IFS= read -r file; do
# 		h2s "${file}"
# 	done
	
# 	for basename in gcc g++ gcc-ar gcc-nm gcc-ranlib; do
# 		for pattern in "${basename}" "${TARGET}-${basename}"; do
# 			if test -e "${pattern}"; then
# 				h2s "${pattern}"
# 			fi
# 		done
# 	done
# )

# 	## Test toolchain
# 	"${OUTPUT}/bin/${TARGET}-gcc" -xc - <<EOF
# #include <stdio.h>
# int main() {
# printf("%s\n", "Hello, C!");
# return 0;
# }
# EOF

# 	"${OUTPUT}/bin/${TARGET}-g++" -xc++ - <<EOF
# 	#include <iostream>
# using namespace std;
# int main() {
#   cout << "Hello, C++!\n";
#   return 0;
# }
# EOF
