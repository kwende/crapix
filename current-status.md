# Current Status

Last updated: 2026-07-17
Branch: `3-Fast_Workflow_Skeleton`
Current commit before this documentation update: e9460fd

## Mission

Build Crapix, a toy 64-bit RISC-V operating system, as an educational project.

The goal is understanding, not automation. The project should proceed slowly,
with each file, instruction, linker directive, and emulator option explained
well enough that the user can reason about the machine instead of trusting a
black box.

## Handoff Summary

The starting handoff established these decisions:

- Build a toy OS for learning operating-system fundamentals.
- Do not create a production OS.
- Do not generate large blobs of magical code.
- Use 64-bit RISC-V.
- Use QEMU system emulation.
- Use QEMU machine `virt`.
- Use WSL2 Ubuntu as the selected path of least resistance.
- Remote Linux remains acceptable later if it becomes more convenient.
- Native Windows/MSYS2 is possible but likely more fiddly.

## Why RISC-V

RISC-V was chosen because it balances readability with real OS concepts.

- x86/x86-64 has too much historical baggage for this learning goal.
- 6502 is excellent for learning assembly but lacks many modern OS mechanisms.
- AArch64 would be viable, but RISC-V is cleaner and more transparent for this
  project.

## Current Repo Snapshot

The repo currently contains documentation and workflow scaffolding only:

- `AGENTS.md`: collaboration contract and repo ritual.
- `README.md`: under-the-hood teaching guide and first-milestone explanation.
- `current-status.md`: this living project memory.
- `tools/setup-ubuntu.sh`: reproducible Ubuntu/WSL package setup and
  toolchain check script.
- `Makefile`: first workflow skeleton, with real `check-toolchain` and stubbed
  `run`, `debug`, `gdb`, and `disasm` targets.
- `linker.ld`: minimal layout draft with `_start` as the entry symbol and
  `0x80000000` as the initial image base.
- `.gitattributes` and `.editorconfig`: LF line-ending guardrails.

No kernel code or real QEMU runner exists yet; only a minimal linker script draft
has been added.

## Selected Development Host

The selected host workflow is WSL2 Ubuntu.

Verified on 2026-06-27:

- Windows WSL distro: `Ubuntu-24.04`
- WSL version: `2`
- Ubuntu version: `24.04.4 LTS`
- Repo path from WSL: `/mnt/c/repos/crapix`
- Normal future run location: `/mnt/c/repos/crapix`

Fresh Ubuntu setup should be reproducible with:

```bash
cd /mnt/c/repos/crapix
bash tools/setup-ubuntu.sh
```

The check-only path is:

```bash
bash tools/setup-ubuntu.sh --check-only
```

## First Milestone

Boot a minimal RISC-V kernel in QEMU and print a message to the serial console.

The concept path to understand is:

1. QEMU creates the virtual machine.
2. The guest CPU starts executing at an entry point.
3. A linker script places code and data at expected addresses.
4. Tiny assembly sets up the minimum CPU state.
5. A stack is established.
6. Control transfers into C.
7. C writes bytes to the UART memory-mapped I/O address.
8. QEMU displays those UART bytes in the terminal.

## Immediate Next Action

Add one minimal assembly entry file that defines `_start` and loops forever.

Keep this step focused on the first executable instruction path:

- assemble the entry file,
- link it with `linker.ld`,
- inspect the ELF entry point and `.text` placement,
- load it with QEMU,
- and confirm that the guest remains in the intentional loop.

Do not add stack setup, C, UART code, or the GDB workflow yet.

## Verified WSL2 Toolchain

Verified on 2026-06-27 inside `Ubuntu-24.04`:

```text
QEMU emulator version 8.2.2 (Debian 1:8.2.2+ds-0ubuntu1.17)
virt                 RISC-V VirtIO board
riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0
GNU ld (2.42-1ubuntu1+6) 2.42
GNU objdump (2.42-1ubuntu1+6) 2.42
GNU gdb (Ubuntu 15.1-1ubuntu1~24.04.1) 15.1
GNU Make 4.3
```

## First QEMU Command Shape

Verified on 2026-07-11:

```bash
qemu-system-riscv64 \
  -machine virt \
  -m 128M \
  -nographic \
  -serial mon:stdio \
  -bios none \
  -S
```

The command starts successfully when wrapped with a short timeout. `-S` pauses
the virtual CPU at startup, which is useful for confirming that QEMU accepts
the machine/options even before Crapix has a kernel image.

The future kernel-loading form will add:

```bash
-kernel build/crapix.elf
```

No disk image is needed for the first milestone. QEMU will load the ELF from
the host into guest memory; storage devices come later after Crapix can talk to
a virtual block device.

## Bite-Sized 10-Day Plan

This is a pacing plan, not a promise to have a real operating system after 10
days. Each day should be capped at roughly 30 minutes and should stop at a
clean learning checkpoint.

| Day | 30-minute focus | Stop when |
| --- | --- | --- |
| 1 | Decide the actual dev host: WSL2 Ubuntu vs remote Linux. | We know the shell, distro, repo path, and where `make run` will happen. |
| 2 | Verify or install QEMU, RISC-V GCC/binutils, Make, and GDB. | `qemu-system-riscv64 --version`, `qemu-system-riscv64 --machine help`, and `riscv64-unknown-elf-gcc --version` all work. |
| 3 | Create only the fast workflow skeleton. | `make check-toolchain` reports the environment clearly. |
| 4 | Learn the QEMU `virt` command at arm's length. | The chosen QEMU command and each flag are documented. |
| 5 | Add a minimal linker script draft. | Sections, entry symbol, and address choices are understood. |
| 6 | Add one assembly entry file with an infinite loop. | QEMU boots into our code and "does nothing" successfully. |
| 7 | Add the GDB workflow. | QEMU can wait for GDB, and GDB can inspect `pc` plus one instruction. |
| 8 | Add stack setup in assembly. | GDB confirms `sp` is set to the intended value. |
| 9 | Add a C entry function and jump/call into it. | GDB proves control reached C. |
| 10 | Add UART serial output. | `make run` prints the first Crapix message in the terminal. |

## Current Gaps And Risks

- Toolchain is verified in WSL2 Ubuntu.
- Host Linux distribution is confirmed as WSL2 `Ubuntu-24.04`.
- Package names for Ubuntu 24.04 have been checked through apt metadata:
  `qemu-system-misc`, `gcc-riscv64-unknown-elf`,
  `binutils-riscv64-unknown-elf`, `gdb-multiarch`, `make`, `git`, and
  `ca-certificates`.
- No assembly or C source layout exists yet.
- `linker.ld` currently chooses `0x80000000`, declares `_start`, and places the
  standard code/data sections, but no ELF has yet verified those choices.
- No stack layout or UART address has been selected or verified yet.
- The biggest process risk is moving too fast and hiding important concepts in
  generated scaffolding.

## Working Convention

After meaningful work sessions, append a dated log entry with:

- what changed,
- why it matters,
- what was verified,
- what remains open,
- and the most likely next step.

In a fresh Codex session, a good prompt is:

```text
Read AGENTS.md, README.md, and current-status.md, then help me with ...
```

## Session Log

### 2026-07-17

- Reconciled `AGENTS.md`, `README.md`, and `current-status.md` with the existing
  `linker.ld` draft.
- Recorded Days 1 through 5 as complete and made the Day 6 assembly entry the
  immediate next checkpoint.
- Documented the current linker contract: ELF entry symbol `_start`, image base
  `0x80000000`, and ordered `.text`, `.rodata`, `.data`, and `.bss` sections.
- Clarified that the layout is drafted but not yet verified by a linked ELF or
  a QEMU boot.
- Fixed the missing Markdown fence in the documented QEMU command.
- Most likely next step: add the smallest `_start` assembly loop, link it, and
  verify the ELF layout before adding a stack or C code.

### 2026-07-11

- Confirmed the Day 4 QEMU command shape for the `virt` machine.
- Verified QEMU reports `virt` as `RISC-V VirtIO board`.
- Verified the no-kernel command starts successfully when paused with `-S` and
  killed by a timeout:
  `qemu-system-riscv64 -machine virt -m 128M -nographic -serial mon:stdio -bios none -S`.
- Captured the conceptual model: QEMU creates the virtual RISC-V board, later
  `-kernel build/crapix.elf` will load the kernel into guest memory, and disk
  images are unnecessary until Crapix has block-device/filesystem support.
- Most likely next step: Day 5, add a minimal linker script draft and document
  the entry symbol, section placement, and address assumptions.

### 2026-06-27

- Closed the Day 1 dev-host decision: Crapix will use WSL2 Ubuntu as the normal
  local development host.
- Verified the available WSL distro is `Ubuntu-24.04`, WSL version `2`, running
  Ubuntu `24.04.4 LTS`.
- Verified the repo path from WSL is `/mnt/c/repos/crapix`; this is where
  future `make run` and QEMU/GDB commands should execute.
- Checked Ubuntu 24.04 apt metadata for the expected reproducible setup
  packages: `qemu-system-misc`, `gcc-riscv64-unknown-elf`,
  `binutils-riscv64-unknown-elf`, `gdb-multiarch`, `make`, `git`, and
  `ca-certificates`.
- Added `tools/setup-ubuntu.sh` so a fresh Ubuntu environment can install or
  check the expected toolchain without relying on memory.
- Current WSL tool state before running the setup script: `make`, `git`, and
  `ca-certificates` are present; QEMU RISC-V, RISC-V bare-metal GCC/binutils,
  and `gdb-multiarch` are not present yet.
- Most likely next step: run `bash tools/setup-ubuntu.sh` from WSL, then use
  its output to close Day 2 once the toolchain commands are verified.
- Ran the setup script successfully and verified the installed WSL2 toolchain:
  QEMU `8.2.2`, QEMU `virt` machine support, RISC-V GCC `13.2.0`, binutils
  `2.42`, GDB `15.1`, and Make `4.3`.
- Closed the Day 2 toolchain verification issue. The next task is Day 3:
  create the fast workflow skeleton without adding kernel code yet.

### 2026-06-25

- Read the Codex handoff document for the toy RISC-V operating system.
- Reviewed the documentation patterns from `C:\repos\cv2` and `C:\repos\wrfv3`.
- Initialized Crapix with repo-level `AGENTS.md`, `README.md`, and
  `current-status.md`.
- Captured the core working agreement: slow educational progress, no large
  magical code dumps, and toolchain verification before kernel generation.
- Most likely next step: confirm the Linux target environment and verify QEMU,
  the RISC-V bare-metal compiler, debugger, and `make`.
- Added the first 10-day bite-sized plan, capped around 30 minutes per session,
  with the first arc focused on WSL2/SSH choice, toolchain verification, a
  Make-based run/debug loop, then the smallest possible assembly-to-C-to-UART
  boot path.
- Created GitHub issues `#1` through `#10` in `kwende/crapix`, one per day of
  the bite-sized plan, so the setup and first boot path can be tracked without
  reopening the docs every time.
