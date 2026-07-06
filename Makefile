.PHONY: check-toolchain run debug gdb disasm clean

check-toolchain:
	bash tools/setup-ubuntu.sh --check-only

run:
	@echo "No kernel image exists yet. This target starts doing real work on Day 6."

debug:
	@echo "No kernel image exists yet. Debug workflow starts on Day 7."

gdb:
	@echo "No kernel image exists yet. GDB workflow starts on Day 7."

disasm:
	@echo "No kernel image exists yet. Disassembly workflow starts once we have an ELF to inspect."

clean:
	@rm -rf build
