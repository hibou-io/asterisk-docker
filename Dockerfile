FROM debian:jessie
MAINTAINER Hibou Corp. <hello@hibou.io>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        openssl \
        libxml2-dev \
        libncurses5-dev \
        uuid-dev \
        sqlite3 \
        libsqlite3-dev \
        pkg-config \
        libjansson-dev \
        libssl-dev \
        curl \
        msmtp \
	dos2unix \
	lame

# Asterisk expects /usr/sbin/sendmail
RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail

COPY sendmailmp3 /usr/sbin/sendmailmp3
RUN chmod 755 /usr/sbin/sendmailmp3

ENV SRTP_VERSION 1.4.4
RUN cd /tmp \
    && curl -o srtp.tgz http://kent.dl.sourceforge.net/project/srtp/srtp/${SRTP_VERSION}/srtp-${SRTP_VERSION}.tgz \
    && tar xzf srtp.tgz
RUN cd /tmp/srtp* \
    && ./configure CFLAGS=-fPIC \
    && make \
    && make install


ENV ASTERISK_VERSION 14.5.0
RUN cd /tmp && curl -o asterisk.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz \
    && tar xzf asterisk.tar.gz
RUN cd /tmp/asterisk* \
    && ./configure --with-pjproject-bundled --with-crypto --with-ssl \
    && make \
    && make install \
    && make samples \
    && make config

CMD asterisk -fvvv
