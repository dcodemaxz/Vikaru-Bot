.PHONY: install install-linux install-termux start run

# Detect environment (Termux vs Linux)
ENV := $(shell \
	if [ -n "$$TERMUX_VERSION" ]; then \
		echo termux; \
	elif [ -d "/data/data/com.termux/files/usr" ]; then \
		echo termux; \
	else \
		echo linux; \
	fi \
)

# Main entry
install:
	@echo "\n🔍 Detected environment: $(ENV)"
ifeq ($(ENV),termux)
	@$(MAKE) install-termux
else
	@$(MAKE) install-linux
endif

# Linux (Ubuntu / Debian / VPS)
install-linux:
	@echo "\n🚀 Installing dependencies for Linux...\n"
	sudo apt install -y git bash pv bc curl python3 python3-pip ffmpeg
	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	sudo apt install -y nodejs
	sudo wget -q https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
		-O /usr/local/bin/yt-dlp
	sudo chmod a+rx /usr/local/bin/yt-dlp
	@yt-dlp --version

# Termux (Android / Emulator)
install-termux:
	@echo "\n🚀 Installing dependencies for Termux...\n"
	pkg install -y git bash pv bc python nodejs ffmpeg wget
	wget -q https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
	chmod a+rx yt-dlp
	mv yt-dlp $$PREFIX/bin/
	@yt-dlp --version

# Start
start:
	@echo "\n▶️  Starting vikaru-bot...\n"
	bash start

run: start
