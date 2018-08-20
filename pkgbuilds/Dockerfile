FROM archlinux/base

RUN mkdir -p /app/repo
WORKDIR "/app"

# Apply custom config for pacman and makepkg
COPY ./pacman.conf /etc/pacman.conf
COPY ./makepkg.conf /etc/makepkg.conf
COPY ./pkg ./pkg

# Install base dependencies
RUN pacman -Syu --noconfirm base-devel wget sudo devtools

# Add builduser with passwordless sudo rights
RUN useradd builduser -m \
 && passwd -d builduser \
 && printf "builduser ALL=(ALL) ALL\n" | tee -a /etc/sudoers \
 && chown -R builduser /app

# Switch from root to builduser
USER builduser

# Install aurutils
RUN gpg --recv-key 6BC26A17B9B7018A \
 && wget "https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz" \
 && tar -xf aurutils.tar.gz \
 && cd aurutils \
 && makepkg -sci --noconfirm

# Make sure permissions are correct
RUN sudo chown -R builduser /app/{repo,pkg}
VOLUME /app/repo

# Add build script
COPY ./build_packages.sh ./build_packages.sh

# Execture build_packages command
CMD bash ./build_packages.sh
