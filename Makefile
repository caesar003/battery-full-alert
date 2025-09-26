VERSION := $(shell cat VERSION)
PACKAGE_NAME := battery-full-alert

# Put everything in dist/
DISTDIR := dist
PACKAGE_DIR := $(DISTDIR)/$(PACKAGE_NAME)_$(VERSION)_all
DEB_FILE := $(DISTDIR)/$(PACKAGE_NAME)_$(VERSION)_all.deb

# Installation paths for system-wide installation
PREFIX := /usr
BINDIR := $(PREFIX)/bin
SYSCONFDIR := /etc
SYSTEMD_USER_DIR := $(PREFIX)/lib/systemd/user
MANDIR := $(PREFIX)/share/man/man1

.PHONY: all install uninstall clean deb test

all: deb

install:
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(SYSCONFDIR)/$(PACKAGE_NAME)
	install -d $(DESTDIR)$(SYSTEMD_USER_DIR)
	install -d $(DESTDIR)$(MANDIR)

	sed 's/__VERSION__/$(VERSION)/g' src/battery-full-alert.sh > $(DESTDIR)$(BINDIR)/battery-full-alert
	chmod 755 $(DESTDIR)$(BINDIR)/battery-full-alert

	install -m 644 config/battery-full-alert.conf $(DESTDIR)$(SYSCONFDIR)/$(PACKAGE_NAME)/

	install -m 644 config/battery-full-alert.service $(DESTDIR)$(SYSTEMD_USER_DIR)/
	install -m 644 config/battery-full-alert.timer $(DESTDIR)$(SYSTEMD_USER_DIR)/

	sed 's/{{VERSION}}/$(VERSION)/g' manual/battery-full-alert.1 > $(DESTDIR)$(MANDIR)/battery-full-alert.1
	gzip -f $(DESTDIR)$(MANDIR)/battery-full-alert.1

deb: clean
	mkdir -p $(PACKAGE_DIR)
	$(MAKE) install DESTDIR=$(PACKAGE_DIR)

	mkdir -p $(PACKAGE_DIR)/DEBIAN
	sed 's/Version: 0.0.0/Version: $(VERSION)/g' DEBIAN/control > $(PACKAGE_DIR)/DEBIAN/control
	cp DEBIAN/postinst DEBIAN/prerm DEBIAN/postrm $(PACKAGE_DIR)/DEBIAN/ 2>/dev/null || true

	chmod 755 $(PACKAGE_DIR)/DEBIAN/postinst $(PACKAGE_DIR)/DEBIAN/prerm $(PACKAGE_DIR)/DEBIAN/postrm 2>/dev/null || true

	# Build package directly into dist/
	dpkg-deb --build $(PACKAGE_DIR) $(DEB_FILE)

	@echo "✅ Debian package built: $(DEB_FILE)"

test:
	@echo "Testing dependencies..."
	@command -v upower >/dev/null || (echo "❌ upower not found"; exit 1)
	@command -v notify-send >/dev/null || (echo "❌ notify-send not found"; exit 1)
	@command -v paplay >/dev/null || (echo "❌ paplay not found"; exit 1)
	@echo "✅ All dependencies found"

clean:
	rm -rf $(DISTDIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/battery-full-alert
	rm -rf $(DESTDIR)$(SYSCONFDIR)/$(PACKAGE_NAME)
	rm -f $(DESTDIR)$(SYSTEMD_USER_DIR)/battery-full-alert.service
	rm -f $(DESTDIR)$(SYSTEMD_USER_DIR)/battery-full-alert.timer
	rm -f $(DESTDIR)$(MANDIR)/battery-full-alert.1.gz
