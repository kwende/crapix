# Crapix: A Toy RISC-V Operating System

Crapix is a deliberately small 64-bit RISC-V operating-system project for
learning how kernels work from the bottom up.

The name is an inside joke. The learning goal is real.

## Why This Exists

This repo is not trying to become a production operating system. It is a place
to learn the path from "QEMU starts a virtual CPU" to "our own code handles
interrupts, memory, and eventually simple user-like programs."

The project should stay understandable. Whenever a file, instruction, linker
rule, or emulator option appears, the repo should be able to explain why it is
there.

## Current State

The repository has project memory, reproducible WSL2 setup, LF line-ending
guardrails, and a first Makefile workflow skeleton.

No kernel source or real QEMU runner has been added yet. That is intentional. The
current `run`, `debug`, and `gdb` Make targets are stubs until there is a kernel
image to load.

## Chosen Architecture

Crapix targets:

- 64-bit RISC-V,
- QEMU system emulation,
- QEMU machine `virt`,
- a bare-metal cross compiler such as `riscv64-unknown-elf-gcc`.

RISC-V is a good fit here because the instruction set is relatively clean while
still supporting modern OS topics such as privilege modes, traps, timer
interrupts, and page tables.

## Host Workflow

Selected path:

1. Use WSL2 Ubuntu on this machine.
2. Keep the repo at `C:\repos\crapix`.
3. From WSL, work in `/mnt/c/repos/crapix`.
4. Use a Linux machine over SSH only if it becomes more convenient later.
5. Treat native Windows/MSYS2 as possible but lower-priority.

The current default WSL distro is `Ubuntu-24.04`, verified as Ubuntu `24.04.4 LTS`.

Fresh Ubuntu setup should be reproducible from the repo:

```bash
cd /mnt/c/repos/crapix
bash tools/setup-ubuntu.sh
```

To check without installing packages:

```bash
bash tools/setup-ubuntu.sh --check-only
```

The repo should eventually support this simple loop from the repo root:

```bash
make check-toolchain
make run
make debug
make gdb
make disasm
make clean
```

No deployment, browser, server, or remote copy step should be required for the
normal learning loop. Edit, run QEMU, inspect terminal/GDB output, stop.

## First Toolchain Check

Before generating kernel files, verify these tools:

```bash
qemu-system-riscv64 --version
qemu-system-riscv64 --machine help
riscv64-unknown-elf-gcc --version
make --version
```

Also locate a debugger:

```bash
gdb-multiarch --version
```

or:

```bash
gdb --version
```

What each tool does:

- `qemu-system-riscv64` emulates the whole RISC-V machine.
- `--machine help` proves QEMU knows about the board models available on this
  host, including the expected `virt` machine.
- `riscv64-unknown-elf-gcc` builds freestanding RISC-V code that does not
  target Linux user space.
- `make` gives us a small repeatable build entry point.
- `gdb` or `gdb-multiarch` lets us stop the emulated CPU, inspect registers,
  and step through early boot code.

## First QEMU Shape

The first QEMU machine shape is:

```bash
qemu-system-riscv64 \
  -machine virt \
  -m 128M \
  -nographic \
  -serial mon:stdio \
  -bios none \
  -S

What those flags mean:

- `-machine virt`: create QEMU's generic RISC-V virtual board.
- `-m 128M`: give the guest machine 128 MiB of RAM.
- `-nographic`: do not open a graphical window; use the terminal.
- `-serial mon:stdio`: connect the guest serial port and QEMU monitor to the
  host terminal.
- `-bios none`: skip firmware for the first bare-metal path.
- `-S`: pause the virtual CPU at startup (useful for validating options before a kernel image exists).

Once Crapix has a kernel image, the command will add something like:

```bash
-kernel build/crapix.elf
```

Early Crapix does not need a disk image. QEMU will load the kernel ELF from the
host into guest memory, then the virtual CPU will execute it. When QEMU exits,
guest RAM and CPU state disappear. Disk images come later, after Crapix has a
block-device driver and enough filesystem code for "mounting" to mean
something inside the guest OS.

## First Milestone

Boot a minimal kernel in QEMU and print a message to the serial console.

The learning path for that milestone is:

1. QEMU creates a virtual RISC-V `virt` machine.
2. The guest CPU starts executing at the configured entry point.
3. A linker script places code and data at the addresses the boot path expects.
4. Tiny assembly establishes the minimum early CPU state.
5. The assembly creates a stack.
6. Control transfers into C.
7. C writes bytes to the UART's memory-mapped I/O address.
8. QEMU displays those UART bytes in the terminal.

That first kernel will likely need only three conceptual files:

- an assembly entry file,
- a linker script,
- and a tiny C file that writes to the UART.

Those files should be introduced only after the toolchain is confirmed, and
each one should be explained as it is added.

## 10-Day Bite-Sized Plan

This plan is not "build an operating system in 10 days." It is a small-session
forecast for getting from an empty repo to the first serial-console milestone.
Each day should fit in about 30 minutes.

| Day | Goal | Stop when |
| --- | --- | --- |
| 1 | Choose the actual dev host: WSL2 Ubuntu or remote Linux. | We know the shell, distro, repo path, and where `make run` will happen. |
| 2 | Verify or install the toolchain. | QEMU, RISC-V GCC/binutils, Make, and GDB commands are located. |
| 3 | Create the workflow skeleton only. | `make check-toolchain` gives a clean environment report. |
| 4 | Inspect the QEMU `virt` command before using it for real. | The README explains the chosen QEMU command and flags. |
| 5 | Add a tiny linker script draft. | We understand sections, the entry symbol, and why addresses matter. |
| 6 | Add one assembly entry file with an infinite loop. | `make run` boots QEMU into our code and does nothing successfully. |
| 7 | Add the debugger loop. | `make debug` and `make gdb` let us inspect `pc` and one instruction. |
| 8 | Add stack setup in assembly. | GDB shows `sp` has the intended value. |
| 9 | Add a C entry function and transfer control to it. | GDB proves control reached C. |
| 10 | Add UART serial output. | `make run` prints the first Crapix message in the terminal. |

## Teaching Rule

Do not paste a full operating system skeleton into this repo.

Prefer a small change, an explanation, a verification command, and then the next
small change. Crapix should be a notebook as much as a codebase.

## Maintenance Rule

Update `README.md` whenever a change affects:

- boot flow,
- linker layout,
- QEMU command-line flags,
- RISC-V privilege or trap behavior,
- memory-mapped device addresses,
- stack setup,
- build commands,
- or debugger workflow.

Update `current-status.md` after meaningful sessions so future work can resume
without rediscovering the same context.
