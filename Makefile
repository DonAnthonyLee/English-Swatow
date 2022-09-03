DEST=./out/book
ORIGINAL_DIR=./original
PATCHES_DIR=./patches
PATCHES=$(shell ls "$(PATCHES_DIR)")

all:
	@printf "\e[32mCreating directory "$(DEST)"\e[0m ...\n"
	@mkdir -p "$(DEST)"
	@printf "\e[32mCopy original contents to the directory\e[0m ...\n"
	@cp -af "$(ORIGINAL_DIR)"/* "$(DEST)/"
	@for f in $(PATCHES) .none; do \
		(test $$f = .none || printf "\e[32mApplying $$f\e[0m ...\n") && \
		(test $$f = .none || patch --binary -p1 -d "$(DEST)" < "$(PATCHES_DIR)/$$f") \
	done
	@printf "\n\e[33mThe book has been generated, which directory located at \"$(DEST)\".\e[0m\n"

