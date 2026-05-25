# Toolchain
ASM = nasm
LINKER = ld

# Flags
ASMFLAGS = -f elf64
LINKERFLAGS = 

# Directories
BUILD_DIR = build

# Filenames
TARGET = $(BUILD_DIR)/scriptor
SRC = scriptor.asm
OBJ = $(patsubst %.asm,$(BUILD_DIR)/%.o,$(SRC))

.PHONY: all clean run

all: $(TARGET)

# Linking
$(TARGET): $(OBJ) | $(BUILD_DIR)
	$(LINKER) $(LINKERFLAGS) -o $@ $^

# Assemble
$(BUILD_DIR)/%.o: %.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

# Directory creator
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build & run
run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BUILD_DIR)