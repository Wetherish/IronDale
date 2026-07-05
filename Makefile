# Variables
CC = odin
SRC = .
OUTPUT = build/main
FLAGS = -vet -strict-style

# Default target: Build and run the project
.PHONY: run
run:
	$(CC) run $(SRC) $(FLAGS)

.PHONY: debug
debug:
	$(CC) run $(SRC) $(FLAGS) -debug -- --debug

.PHONY: test
test:
	$(CC) test $(SRC) $(FLAGS) -all-packages -define:ODIN_TEST_THREADS=1

# Build the project without running it
.PHONY: build
build:
	@mkdir -p build
	$(CC) build $(SRC) -out=$(OUTPUT) $(FLAGS)

# Build with optimizations for release
.PHONY: release
release:
	@mkdir -p build
	$(CC) build $(SRC) -out=$(OUTPUT) -o:speed $(FLAGS)

# Clean up build artifacts
.PHONY: clean
clean:
	rm -rf build/
