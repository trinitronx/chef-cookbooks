#!/usr/bin/perl -w
#
# =========================== SUMMARY =====================================
# File name: check_netscaler_vserver.pl
# Author : Tom Geissler	<Tom.Geissler@perdata.de>
#			<Tom@d7031.de>
# Date : 21.02.2012
# =========================== LICENSE =====================================
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# ========================== ABOUT THIS PLUGIN ===========================
#
# This plugin for icinga/nagios checks the health of load balancing virtual
# server configured on netscaler.
#
# status information:
# OK = 100 %, All backends available and vserver is up.
# Warning = 0 % (or critical) < x < 100 % (or warning), Some backends are 
# down. vserver still working
# Critical = 0 % (or critical), All backends unreachable and vserver is down
#
# This script is tested with Netscaler 9.3
# see also http://support.citrix.com/article/CTX128676
#
# use "show snmp oid VSERVER" on netscaler to get the oid's
# A version using vserver name will follow.
#
# This script require Net::SNMP
#
# ========================================================================

use lib "/usr/local/nagios/libexec";
use utils qw($TIMEOUT %ERRORS &print_revision &support);
use Getopt::Long;
use Net::SNMP;

use vars qw($script_name $script_version $o_host $o_community $o_port $o_vserver $o_help $o_version $o_timeout $o_debug $o_warning $o_critical);

use strict;

#========================================================================= 

$script_name = "check_netscaler_vserver.pl";
$script_version = "0.2";

$o_host = undef;
$o_community = "public";
$o_port = 161;
$o_help = undef;
$o_version = undef;
$o_timeout = 10;
$o_warning = 99;
$o_critical = 0;
$o_vserver = undef;

my $return_string = "";
my $state = "UNKNOWN";
my $exitstate = 3;

#============================= get options ===============================

check_options();

#============================= SNMP ======================================

my $oid_prefix = "1.3.6.1.4.1.5951";
my $oid_Health = $oid_prefix.".4.1.3.1.1.62.";
my $oid_vsvrHealth = $oid_Health.$o_vserver;			

#============================= main ======================================

# Opening SNMP Session
my $session = &open_session();
if (!defined($session)) {
	print "ERROR opening session: $return_string\n";
	exit $ERRORS{"UNKNOWN"};
}

if(defined($o_vserver)) {
	my $vserver = &get_vserver_health($session);
	if($vserver > $o_warning) {
                $state= "OK";
		$exitstate = 0;
        }
        else {
                if (($vserver > $o_critical) && ($vserver < $o_warning)) {
                        $state = "WARNING";
			$exitstate = 1;
                } else {
                        $state = "CRITICAL";
			$exitstate = 2;
                }
        }

	# Closing SNMP Session
	&close_session($session);

	if (defined($state) && defined($return_string)) {
                $return_string = $state.", vserver health: ".$vserver." %";
		print "$return_string\n"; 
	exit ($exitstate);
	}
}

exit ($exitstate);


#============================ functions ==================================

sub open_session {
	my ($session, $str) = Net::SNMP->session(
		-hostname	=> $o_host,
		-community	=> $o_community,
		-port		=> $o_port,
		-timeout	=> $o_timeout
	);

	return $session;
}


sub close_session {
	my ($session) = @_;

	if(defined($session)){
		$session->close;
	}
}

sub get_vserver_health {
	my ($session) = @_;
	my $vserver_health;

	my $result = $session->get_request(
		-varbindlist => [$oid_vsvrHealth]
        );

        if (!defined($result)) {
                $return_string = "Error : ".$session->error;
                $state = "UNKNOWN";
		exit 3;
        }
        else {
		$vserver_health = $result->{$oid_vsvrHealth};
        }

	return $vserver_health;
}

sub usage {
	print "Usage: $0 -H <host> -C <community> [-p <port>] [-t <timeout>] [-w <warning>] [-c <critical>] -S <vserver-oid> [-V] [-h]\n";
}


sub version {
	print "$script_name v$script_version\n";
}


sub help {
	version();
	usage();

	print <<HELP;
	-h, --help
   		print this help message
	-H, --hostname=HOST
		name or IP address of host to check
	-C, --community=COMMUNITY NAME
		community name for the host's SNMP agent (implies v1 protocol)
	-w, --warning
		integer threshold for warning level on percent vserver health, 0 < x < 100
	-c, --critical
		 integer threshold for critical level on percent vserver health, default 0
	-P, --port=PORT
		SNMP port (Default 161)
	-t, --timeout=INTEGER
		timeout for SNMP
	-V, --version
		version number
        -S, --vserver
                vserver numeric OID, use "show snmp oid VSERVER"
HELP
}



sub check_options {
	Getopt::Long::Configure("bundling");
	GetOptions(
		'h'	=> \$o_help,		'help'		=> \$o_help,
		'H:s'	=> \$o_host,		'hostname:s'	=> \$o_host,
		'P:i'	=> \$o_port,		'port:i'	=> \$o_port,
		'C:s'	=> \$o_community,	'community:s'	=> \$o_community,
		't:i'	=> \$o_timeout,		'timeout:i'	=> \$o_timeout,
		'V'	=> \$o_version,		'version'	=> \$o_version,
		'w:i'	=> \$o_warning,		'warning:i'	=> \$o_warning,
		'c:i'	=> \$o_critical,	'critical:i'	=> \$o_critical,
		'S=s'	=> \$o_vserver,		'vserver=s'	=> \$o_vserver
	);

	if(defined($o_help)) {
		help(); 
		exit $ERRORS{'UNKNOWN'};
	}

	if(defined($o_version)) {
		version();
		exit $ERRORS{'UNKNOWN'};
	}

	if(!defined($o_host) || !defined($o_community)) {
		usage();
		exit $ERRORS{'UNKNOWN'};
	}

	if(!defined($o_vserver)) {
                usage();
                exit $ERRORS{'UNKNOWN'};
        }

}

