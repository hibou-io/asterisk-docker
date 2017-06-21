***********************
Hibou - Asterisk Docker
***********************

This Dockerfile provides an easy way to get Asterisk up and running on Docker based infrastructure.

Branches are named after Asterisk major releases. Tags provide minor releases.

=============
Main Features
=============
* Modern features such as PJSIP
* Ability to send email through msmtp

=====
Usage
=====

You will likely want to create a docker-compose.yml file with something similar to this.

docker-compose.yml::

    version: '2'
    services:
      asterisk:
        image: hibou/asterisk:14
        ports:
         - "192.168.100.10:5060:5060/udp"
         - "192.168.100.10:5060:5060/tcp"
         - "192.168.100.10:10000-10099:10000-10099/udp"
         - "192.168.100.10:8088:8088"
         - "192.168.100.10:8089:8089"
        volumes:
         - "./var/conf/msmtprc:/etc/msmtprc"
         - "./var/conf/asterisk:/etc/asterisk"
         - "./var/data/asterisk:/var/lib/asterisk"
         - "./var/data/asterisk-spool:/var/spool/asterisk"
         - "./var/ssl:/ssl"
        networks:
          default:
            ipv4_address: 10.1.2.10

    networks:
      default:
        ipam:
          config:
          - subnet: 10.1.2.0/24

This assumes a lot, but should provide a reasonable structure for things like your Asterisk configuration
(`/etc/asterisk`) and setting up a static IP for the container in its own subnet for easier NAT workarounds.

This setup is flexible enough to provide custom IVR's, inbound SIP Trunks, both SIP based phones and WebRTC clients,
and voicemail via email.

Initial Configuration
=====================

When you first start working, you may want access to the default configuration and data directories.  Simply mount them
somewhere else on the system and then copy the existing directories into your external ones.

volumes::

         - "./var/conf/asterisk:/ic"
         - "./var/data/asterisk:/id"
         - "./var/data/asterisk-spool:/ids"

`docker-compose run --rm asterisk bash -c "cp -R /etc/asterisk/* /ic && cp -R /var/lib/asterisk/* /id &&
cp -R /var/spool/asterisk/* /ids`

You can create a configuration file for msmtp like the following.::

    defaults
    auth on
    tls on
    tls_certcheck off
    logfile /var/log/msmtp.log

    account default
    host mail.your.domain
    port 587
    from pbx@your.domain
    user pbx@your.domain
    password yoursecretpassword

Customization
=============

Obviously you will want to edit your `/etc/asterisk/` files, especially `rtp.conf` to match ports from the outside
world.

License
=======

Hibou maintains this project solely at its own will and provides no warranty.

This project -- Copyright Hibou Corp. 2016.

Asterisk is distributed under the GPLv2

Asterisk -- Copyright Digium Inc.