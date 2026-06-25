# Current Status

Last updated: 2026-06-25
Branch: `main`
Base commit: none yet; repository has no initial commit

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
- Prefer Linux over SSH as the path of least resistance.
- WSL2 is also acceptable.
- Native Windows/MSYS2 is possible but likely more fiddly.

## Why RISC-V

RISC-V was chosen because it balances readability with real OS concepts.

- x86/x86-64 has too much historical baggage for this learning goal.
- 6502 is excellent for learning assembly but lacks many modern OS mechanisms.
- AArch64 would be viable, but RISC-V is cleaner and more transparent for this
  project.

## Current Repo Snapshot

The repo currently contains documentation only:

- `AGENTS.md`: collaboration contract and repo ritual.
- `README.md`: under-the-hood teaching guide and first-milestone explanation.
- `current-status.md`: this living project memory.

No kernel code, linker script, build file, or QEMU runner exists yet.

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

Help Ben set up and verify the Linux toolchain.

Start by confirming the Linux distribution, then install or locate:

- QEMU RISC-V system emulator,
- RISC-V bare-metal GCC/binutils,
- `gdb` or `gdb-multiarch`,
- `make`.

Run and explain:

```bash
qemu-system-riscv64 --version
qemu-system-riscv64 --machine help
riscv64-unknown-elf-gcc --version
```

Only after those checks pass should the first three-file kernel skeleton be
proposed.

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

- Toolchain is not verified yet.
- Host Linux distribution is not confirmed yet.
- No decision has been made about exact package names for the user's chosen
  Linux environment.
- No source layout exists yet.
- No boot address, linker script, stack layout, or UART address has been
  verified in this repo yet.
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
