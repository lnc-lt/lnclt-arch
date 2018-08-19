FROM archlinux/base


# Apply custom config for pacman and makepkg
COPY ./pacman.conf /etc/pacman.conf
COPY ./makepkg.conf /etc/makepkg.conf

# Install base dependencies
RUN pacman -Syu --noconfirm base-devel wget sudo

# Add builduser with passwordless sudo rights
RUN useradd builduser -m \
 && passwd -d builduser \
 && printf "builduser ALL=(ALL) ALL\n" | tee -a /etc/sudoers \
 && chown -R builduser /tmp

# Switch from root to builduser
USER builduser

# Install aurutils
WORKDIR "/tmp"
RUN gpg --recv-key 6BC26A17B9B7018A \
 && wget "https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz" \
 && tar -xf aurutils.tar.gz \
 && cd aurutils \
 && makepkg -sci --noconfirm

# Build packages and add to repository file
WORKDIR "/"
COPY ./build_packages.sh /build_packages.sh

# Set up volumes
VOLUME ./repo /repo
VOLUME ./pkg /pkg

# Execture build_packages command
CMD bash build_packages.sh
