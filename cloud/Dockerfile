# SkullOS Cloud: the same tools and look in a container, as a browser-accessible desktop (noVNC).
# Runs on Modal (see modal_app.py), any Docker host, or Kubernetes.
FROM debian:bookworm
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
      xfce4 xfce4-terminal xfce4-notifyd thunar plank dbus-x11 at-spi2-core \
      tigervnc-standalone-server tigervnc-tools novnc websockify \
      curl wget ca-certificates git sudo gnupg procps less nano htop \
      restic rclone rsync jq zenity libnotify-bin espeak-ng sox \
      fonts-inter fonts-noto-color-emoji sassc libglib2.0-dev-bin gtk2-engines-murrine gnome-themes-extra \
      python3 python3-venv python3-pip xdg-utils x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# Browser: Google Chrome on amd64, Chromium on arm64 (Chrome has no Linux arm64 build)
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      apt-get update && apt-get install -y --no-install-recommends chromium && ln -s /usr/bin/chromium /usr/local/bin/browser-bin; \
    else \
      wget -qO /tmp/c.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
      apt-get update && apt-get install -y /tmp/c.deb && rm /tmp/c.deb && ln -s /usr/bin/google-chrome-stable /usr/local/bin/browser-bin; \
    fi && rm -rf /var/lib/apt/lists/* && \
    printf '#!/bin/sh\nexec browser-bin --no-sandbox --disable-dev-shm-usage --no-first-run "$@"\n' > /usr/local/bin/browser && \
    chmod +x /usr/local/bin/browser && \
    printf '[Desktop Entry]\nType=Application\nName=Browser\nExec=browser %%U\nIcon=web-browser\nCategories=Network;\n' > /usr/share/applications/skull-browser.desktop

# Claude Code
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs && \
    npm install -g @anthropic-ai/claude-code && rm -rf /var/lib/apt/lists/* /root/.npm

# macOS-style theme (WhiteSur)
RUN cd /tmp && git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git && \
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git && \
    (cd WhiteSur-gtk-theme && ./install.sh -d /usr/share/themes -c dark) && \
    (cd WhiteSur-icon-theme && ./install.sh -d /usr/share/icons -t default) && \
    rm -rf /tmp/WhiteSur-*

# Shared SkullOS tools + config
COPY iso/config/includes.chroot/usr/local/bin/ /usr/local/bin/
COPY iso/config/includes.chroot/etc/skel/ /etc/skel/
COPY iso/config/includes.chroot/usr/share/backgrounds/ /usr/share/backgrounds/
COPY iso/config/includes.chroot/usr/share/applications/skull-claude.desktop iso/config/includes.chroot/usr/share/applications/skull-sync-setup.desktop /usr/share/applications/
COPY cloud/start.sh /usr/local/bin/skull-cloud-start
COPY cloud/desktop-init.sh /usr/local/bin/skull-desktop-init
RUN sed -i 's/gnome-terminal --title=Claude --/xfce4-terminal --title=Claude -x/' /usr/share/applications/skull-claude.desktop && \
    rm -f /etc/skel/.config/autostart/skull-welcome.desktop && \
    ln -sf vnc.html /usr/share/novnc/index.html && \
    chmod 755 /usr/local/bin/skull-* && \
    useradd -m -s /bin/bash -G sudo skull && echo 'skull ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/skull

EXPOSE 6080
CMD ["/usr/local/bin/skull-cloud-start"]
