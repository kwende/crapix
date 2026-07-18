# AGENTS.md

## Purpose

This repo is for Crapix, a toy 64-bit RISC-V operating system built for
learning.

Crapix is an inside-joke name, not a production aspiration. The serious goal is
to understand operating-system fundamentals by building a small system from
first principles and keeping every step explainable.

## Project Intent

This project should teach:

- how a virtual machine starts a guest CPU,
- how a linker script places code and data,
- how minimal assembly establishes the earliest CPU state,
- how C code gains control,
- how memory-mapped I/O works,
- and, later, how traps, privilege levels, timers, paging, and process-like
  abstractions fit together.

This is not a race to produce a Unix-like kernel. A smaller, clearer system is
better than a larger system the user cannot inspect comfortably.

## Chosen Platform

- ISA: 64-bit RISC-V.
- Emulator: QEMU system emulation.
- QEMU machine: `virt`.
- Selected host workflow: WSL2 Ubuntu.
- Expected WSL repo path: `/mnt/c/repos/crapix`.
- Remote Linux remains acceptable if it becomes more convenient.
- Native Windows/MSYS2 is lower-priority because it adds setup friction.

RISC-V was chosen because it is clean enough to read and still has the modern
OS concepts we want to study, including privilege modes, traps, timer
interrupts, and page tables.

## Collaboration Agreement

- The user wants to understand each file, instruction, linker directive, build
  command, and QEMU option.
- Do not generate large blobs of magical code.
- Small snippets are fine when they are explained in plain English.
- Prefer discussion, inspection, and incremental construction over dumping a
  finished kernel skeleton.
- When adding code, explain why it exists and what new machine behavior it
  unlocks.
- Keep the user in the driver's seat for conceptual decisions about what to
  learn next.

## Working Style

- Default to slow, inspectable progress.
- Keep sessions bite-sized: target 30 minutes or less for ordinary hobby
  sessions.
- Prefer one concept per step when possible.
- Keep the repo small and readable.
- Use boring build tooling until there is a clear reason to add complexity.
- Do not hide low-level details behind abstractions before the user has seen
  what they are replacing.
- Distinguish facts already verified in this repo from intended next steps.
- Prefer stopping at a clean learning checkpoint over pushing through to a
  bigger deliverable.

## Repo Ritual

Before substantial work:

- Read `current-status.md`.
- Read `README.md` for the current under-the-hood model.
- Check what files already exist instead of assuming a standard OS layout.
- From WSL2, work from `/mnt/c/repos/crapix`.
- If touching build or boot behavior, explain the affected command path before
  editing.

After substantial work:

- Update `current-status.md` with a dated session log entry.
- Update `README.md` when the change affects boot flow, linker layout, CPU
  state, memory addresses, QEMU invocation, or toolchain assumptions.
- Append to the session log instead of rewriting history.

## Immediate Direction

The first milestone is:

Boot a minimal RISC-V kernel in QEMU and print a message to the serial console.

The development loop should be intentionally low-friction:

```bash
make check-toolchain
make run
make debug
make gdb
make disasm
make clean
```

The expected default host is WSL2 Ubuntu unless the user chooses a remote Linux
machine. Avoid adding Docker, web UI, deployment, or native Windows toolchain
work until there is a concrete reason.

The Linux toolchain has been verified in WSL2 Ubuntu. Recheck it at any time
with:

```bash
make check-toolchain
```

The underlying tools are:

```bash
qemu-system-riscv64 --version
qemu-system-riscv64 --machine help
riscv64-unknown-elf-gcc --version
```

The verified environment also includes `make` and `gdb-multiarch`.

## Definitions

- `bare metal`: code running without an operating system underneath it.
- `kernel`: the privileged program we are building.
- `machine`: the virtual hardware model QEMU exposes.
- `virt`: QEMU's generic RISC-V board, useful for OS experiments.
- `MMIO`: memory-mapped I/O, where device registers are accessed through normal
  load/store instructions at special addresses.
- `UART`: a serial device; for the first milestone, writing bytes to the UART is
  how the kernel prints to the terminal.
- `linker script`: the file that tells the linker where code, data, stack
  symbols, and sections should live in the guest address space.
- `entry point`: the first instruction address where the CPU begins executing
  our code.

## Educational Discipline

When making or reviewing low-level changes, keep this evidence chain explicit:

1. What does QEMU provide?
2. Where does the CPU begin?
3. Where did the linker place the relevant symbol or section?
4. Which instruction changes CPU state?
5. Which memory address or register is being read or written?
6. What should we observe in the terminal, debugger, or emulator trace?

If the answer to any of those is unknown, treat it as a learning target rather
than papering over it.

## Session Rule

`current-status.md` is the living project memory. If a session makes meaningful
progress, captures a decision, verifies a tool, or discovers a blocker, record
it there before wrapping.

`README.md` is the living under-the-hood explainer. If boot mechanics, memory
layout, build commands, QEMU flags, or RISC-V concepts change, update it in the
same change so the repo remains useful as a teaching artifact.
