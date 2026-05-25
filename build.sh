#!/bin/sh

set -euo pipefail

nasm -f elf64 scriptor.asm -o build/scriptor.o
ld build/scriptor.o -o build/scriptor
