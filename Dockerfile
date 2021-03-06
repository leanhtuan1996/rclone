FROM alpine:3.5

MAINTAINER Justin <justin.le.1105@gmail.com>

ENV RCLONE_VERSION="current"
ENV ARCH="amd64"
ENV SYNC_SRC_TO_ZIP=
ENV SYNC_SRC=
ENV SYNC_DEST=
ENV SYNC_OPTS=-v
ENV RCLONE_OPTS="--config /config/rclone.conf"
ENV CRON="0 0 * * *"
ENV CRON_ABORT="0 6 * * *"
ENV FORCE_SYNC=
ENV CHECK_URL=
ENV TZ="Asia/Ho_Chi_Minh"

RUN apk -U add ca-certificates fuse wget zip vim dcron tzdata \
    && rm -rf /var/cache/apk/* \
    && cd /tmp \
    && wget -q http://downloads.rclone.org/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
    && unzip /tmp/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
    && rm -r /tmp/rclone*

COPY entrypoint.sh /
COPY sync.sh /
COPY sync-abort.sh /
RUN chmod 777 /entrypoint.sh
RUN chmod 777 /sync.sh
RUN chmod 777 /sync-abort.sh
VOLUME ["/config"]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
