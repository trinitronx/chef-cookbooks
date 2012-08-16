Description
===========

This cookbook is created with the aim of automating a single instance install of the inspircd IRC server.

Requirements
============

* Currently only tested on Ubuntu.
* LDAP authentication options require the use of inspircd packaged with Ubuntu 12.10+, so this is backported for use on 12.04 with the ::default recipe

Attributes
==========

Default attribute values:

[:inspircd][:description] = "My IRC Server"
[:inspircd][:network] = "Localnet"
[:inspircd][:dns_server] = "127.0.0.1"
[:inspircd][:log_type] = "* -USERINPUT -USEROUTPUT"
[:inspircd][:admin_name] = "Server Admin"
[:inspircd][:admin_nick] = "ServerAdmin"
[:inspircd][:admin_email] = "root@irc.local"
[:inspircd][:root_oper_password] = "12345"
[:inspircd][:disabled_commands_stanza] = "<disabled commands=\"NICK MODE\" usermodes=\"\" chanmodes=\"\" fakenonexistant=\"yes\">"
[:inspircd][:binary_location] = "/usr/sbin/inspircd" (or /srv/inspircd/inspircd in ::source recipe)
[:inspircd][:LD_LIBRARY_PATH] = "/usr/lib/inspircd" (or /srv/inspircd/lib in ::source recipe)
[:inspircd][:motd_location] = "/etc/inspircd/motd.conf" (or /srv/inspircd/conf/motd.conf in ::source recipe)
[:inspircd][:rules_location] = "/etc/inspircd/rules.conf" (or /srv/inspircd/conf/rules.conf in ::source recipe)
[:inspircd][:conf_location] = "/etc/inspircd/inspircd.conf" (or /srv/inspircd/conf/inspircd.conf in ::source recipe)
[:inspircd][:start_option] = "" (or "start" in ::source recipe)
[:inspircd][:inspircd_directory] = "" (or "/srv/inspircd" in ::source recipe)
[:inspircd][:ssl_cert_location] = ""
[:inspircd][:ssl_port] = ""
[:inspircd][:ssl_key_location] = ""
[:inspircd][:ssl_subj_stanza] = "" (used during key generation if no key is present)
[:inspircd][:ldap_basedn] = ""
[:inspircd][:ldap_searchattribute] = ""
[:inspircd][:ldap_server] = ""
[:inspircd][:ldap_binduserdn] = ""
[:inspircd][:ldap_bindpass] = ""
[:inspircd][:ldap_basedn_oper] = ""
[:inspircd][:chatlog_location] = ""

Usage
=====


Recipes:

[inspircd::default]
The default recipe will use the packaged version of inspircd in Ubuntu.

This option has not been tested extensively and is currently not recommended

TODO: Need to test and verify this recipe is still working properly



[inspircd::source]

Out of the box, this should provide a working inspircd installation in /srv/inspircd. Simply change your role/node attributes to override the appropriate defaults.
NOTE:  If using SSL, specify the ssl attributes on the server or node's role, and place the cert/key in their specified location


A custom build (including chatlog module) of inspircd is distributed with the cookbook. Below are brief instructions on how to build new versions
* apt-get build-dep inspircd
* apt-get install libldap2-dev
* Pull latest package from https://github.com/inspircd/inspircd/downloads
* Add in chatlog module:
** wget -O src/modules/extra/m_chatlog.cpp https://raw.github.com/joshenders/inspircd-m_chatlog/master/m_chatlog.cpp
*  ./configure --enable-gnutls --prefix=/srv/inspircd ./configure --enable-extras=m_chatlog.cpp --enable-extras=m_ldapauth.cpp --enable-extras=m_ldapoper.cpp
* make
* make install
** This will attempt to start the install to /srv/inspircd -- ensure that it is created
* chown --recursive irc:adm /srv/inspircd
* tar -jcf inspircd_ver.tar.bz2 /srv/inspircd


