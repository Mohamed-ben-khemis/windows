ARG VERSION_ARG="latest"
FROM scratch AS build-amd64

COPY --from=qemux/qemu:6.20 / /

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"
ENV INST_SCRIPTS=/dockerstartup/install \ 
    STARTUPDIR=/dockerstartup \ 
    DESKTOP_PACKAGE=xfce4

### Install core dependencies
COPY ./src/install/core_dependencies $INST_SCRIPTS/core_dependencies/
RUN bash $INST_SCRIPTS/core_dependencies/install_core_dependencies.sh && rm -rf $INST_SCRIPTS/core_dependencies/
COPY ./src/install/xfce $INST_SCRIPTS/xfce/
RUN bash $INST_SCRIPTS/xfce/install_xfce_ui.sh && rm -rf $INST_SCRIPTS/xfce/ \
    && apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN set -eu && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        bc \
        jq \
        curl \
        7zip \
        wsdd \
        samba \
        xz-utils \
        wimtools \
        dos2unix \
        cabextract \
        genisoimage \
        libxml2-utils \
        libarchive-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=755 ./src /run/
COPY --chmod=755 ./assets /run/assets
COPY rootfs /
ADD --chmod=664 https://github.com/qemus/virtiso-whql/releases/download/v1.9.45-0/virtio-win-1.9.45.tar.xz /drivers.txz
RUN chmod +x /usr/local/sbin/init && chmod +x /usr/local/sbin/fakegetty \
  && systemctl --user --global enable display.service \
  && systemctl enable user-init \
  && systemctl --user --global enable pulseaudio 


WORKDIR /root
VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/usr/local/sbin/init"]

FROM dockurr/windows-arm:${VERSION_ARG} AS build-arm64
FROM build-${TARGETARCH}

ARG VERSION_ARG="0.00"
RUN echo "$VERSION_ARG" > /run/version
# Copy XFCE configuration files
ENV XFCE_PERCHANNEL_XML_DIR=xfce-perchannel-xml
COPY ./src/install/xfce/custom_ui.sh /usr/local/bin
RUN chmod +x /usr/local/bin/custom_ui.sh 
COPY ./src/xfce/start_xfce4.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start_xfce4.sh 
COPY systemd/ui-config.service /etc/systemd/user/ui-config.service
COPY  ./src/xfce/  /
COPY systemd/${DESKTOP_PACKAGE}.service /etc/systemd/user/desktop.service





RUN systemctl --user --global enable desktop.service \
  && systemctl disable display-manager \
  && systemctl disable wpa_supplicant \
  && systemctl disable ModemManager \
  && systemctl --user --global enable ui-config.service
VOLUME /storage
EXPOSE 8006 3389

ENV VERSION="11"
ENV RAM_SIZE="4G"
ENV CPU_CORES="2"
ENV DISK_SIZE="64G"

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
