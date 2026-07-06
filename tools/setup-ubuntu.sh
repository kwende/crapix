#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  bash tools/setup-ubuntu.sh
  bash tools/setup-ubuntu.sh --check-only

Installs or verifies the Ubuntu packages used for the Crapix WSL2 workflow.
USAGE
}

check_only=0

case "${1:-}" in
    "")
        ;;
    --check-only)
        check_only=1
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

if [[ ! -r /etc/os-release ]]; then
    echo "Could not read /etc/os-release; this setup script expects Ubuntu or Debian." >&2
    exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

case "${ID:-}:${ID_LIKE:-}" in
    ubuntu:*|debian:*|*:debian*)
        ;;
    *)
        echo "This setup script expects Ubuntu/Debian. Detected: ${PRETTY_NAME:-unknown}" >&2
        exit 1
        ;;
esac

packages=(
    ca-certificates
    git
    make
    qemu-system-misc
    gcc-riscv64-unknown-elf
    binutils-riscv64-unknown-elf
    gdb-multiarch
)

if (( check_only == 0 )); then
    echo "Installing Crapix toolchain packages on ${PRETTY_NAME:-Ubuntu/Debian}..."
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
else
    echo "Checking Crapix toolchain on ${PRETTY_NAME:-Ubuntu/Debian}..."
fi

missing=0

check_command() {
    local command_name="$1"
    local description="$2"

    if command -v "$command_name" >/dev/null 2>&1; then
        printf 'OK      %-28s %s\n' "$command_name" "$description"
    else
        printf 'MISSING %-28s %s\n' "$command_name" "$description"
        missing=1
    fi
}

echo
check_command git "source control"
check_command make "repo command entry point"
check_command qemu-system-riscv64 "RISC-V system emulator"
check_command riscv64-unknown-elf-gcc "bare-metal RISC-V compiler"
check_command riscv64-unknown-elf-ld "bare-metal RISC-V linker"
check_command riscv64-unknown-elf-objdump "RISC-V disassembly/inspection"
check_command gdb-multiarch "debugger for the QEMU/GDB loop"

if command -v qemu-system-riscv64 >/dev/null 2>&1; then
    if qemu-system-riscv64 --machine help | awk '{ print $1 }' | grep -qx 'virt'; then
        echo "OK      qemu virt machine            available"
    else
        echo "MISSING qemu virt machine            not listed by qemu-system-riscv64 --machine help"
        missing=1
    fi
fi

echo
if (( missing != 0 )); then
    if (( check_only != 0 )); then
        echo "Some tools are missing. Run: bash tools/setup-ubuntu.sh"
    else
        echo "Some tools are still missing after install. Check apt output above."
    fi
    exit 1
fi

cat <<'DONE'
Crapix WSL2 setup looks ready.

Expected repo path from WSL:
  cd /mnt/c/repos/crapix

Next normal commands:
  make check-toolchain
  make run
DONE
