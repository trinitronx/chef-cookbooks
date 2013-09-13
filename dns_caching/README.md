Description
===========

This cookbook installs and configures dnsmasq for local DNS caching. It relies on Opscode's resolver cookbook to update /etc/resolv.conf on all systems except Ubuntu 12+ systems.

Requirements
============

Tested on Ubuntu, RHEL, and CentOS systems.

Usage
=====

Create resolver attributes to define DNS nameservers and search domains, preferably at the environment level. The first DNS nameserver defined must be the loopback interface address, usually 127.0.0.1. Once the dns_caching cookbook is assigned to a node and the resolver attributes are defined, the default recipe will install dnsmasq and use the resolver cookbook to update /etc/resolv.conf. On Ubuntu 12+ systems, the resolver cookbook is not used and instead dnsmasq is configured to ignore /etc/resolv.conf and other configuration files created by resolvconf and instead use it's own configuration for nameserver definitions. The resolvconf service will automatically update /etc/resolv.conf to direct DNS requests to dnsmasq once the package is installed.