#!/usr/bin/perl -w
#
# =========================== SUMMARY =====================================
# File name: check_netscaler_ha_status.pl
# Author : Tom Geissler	<Tom.Geissler@perdata.de>
#			<Tom@d7031.de>
# Date : 28.06.2012
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
# This plugin for icinga/nagios checks the high availability on a HA-Cluster of
# two Netscalers.
# There are two ways to check. First is a simple check against the primary. You
# only need to specify the name or address to check.
# An 'exentended' version checks also the secondary and hence the successful 
# failover.
#
# status information:
# "OK, Primary" -> everything is fine, also if --secondary is set
# "WARNING, Secondary" -> Primary has become secondary, failover occured
# "CRITICAL, NO HA MEMBER !" -> Primary is no longer member of a HA-Cluster
# "CRITICAL, HA NOT WORKING !" -> No Primary available, HA broken
#
# This script is tested with Netscaler 9.3
# see also http://support.citrix.com/article/CTX128676
#
# This script require Net::SNMP
#
# ========================================================================

use lib "/usr/local/nagios/libexec";
use utils qw($TIMEOUT %ERRORS &print_revision &support);
use Getopt::Long;
use Net::SNMP;

use vars qw($script_name $script_version $o_primary $o_community $o_port $o_secondary $o_help $o_version $o_timeout $o_debug);

use strict;

#========================================================================= 

$script_name = "check_netscaler_ha_status.pl";
$script_version = "0.1";

$o_primary = undef;
$o_community = "public";
$o_port = 161;
$o_help = undef;
$o_version = undef;
$o_timeout = 10;
$o_secondary = undef;

my $return_string = "";
my $return_ha_status_sec = ""; 
my $state = "UNKNOWN";
my $exitstate = 3;

#============================= get options ===============================

check_options();

#============================= SNMP ======================================

my $oid_prefix = "1.3.6.1.4.1.5951";
my $oid_ha_status = $oid_prefix.".4.1.1.23.3.0";
my $oid_ha_change = $oid_prefix.".4.1.1.23.5.0";

#============================= main ======================================

# Opening secondary SNMP Session if '--secondary' is set
if(defined($o_secondary)) {
	my $session_sec = &open_session_sec();
	if (!defined($session_sec)) {
		print "ERROR opening session: $return_string\n";
		exit $ERRORS{"UNKNOWN"};
	}

	my $ha_status_sec = &get_ha_status($session_sec);

	# Closing SNMP Session
	&close_session_sec($session_sec);

	$return_ha_status_sec = $ha_status_sec;  
}

# Opening primary SNMP Session
my $session_pri = &open_session_pri();
if (!defined($session_pri)) {
	print "ERROR opening session: $return_string\n";
	exit $ERRORS{"UNKNOWN"};
}

if(defined($o_primary)) {
	my $ha_status_pri = &get_ha_status($session_pri);
	my $ha_change = &get_ha_change($session_pri);
	if($ha_status_pri == 2 ) {
                $state= "OK, Primary";
		$exitstate = 0;
        }
        else {
                if ($ha_status_pri == 1 ) {
                        $state = "WARNING, Secondary";
			$exitstate = 1;
                } else {
                        $state = "CRITICAL, NO HA MEMBER !";
			$exitstate = 2;
                }
        }

	# Closing SNMP Session
	&close_session_sec($session_pri);

	if(defined($o_secondary)) {
                if (($ha_status_pri == 1 ) && ($return_ha_status_sec != 2 )) {
                        $state = "CRITICAL, HA NOT WORKING !";
			$exitstate = 2;
		}
	
	}
	if (defined($state) && defined($return_string)) {
                $return_string = $state.", last status change was: ".$ha_change;
		print "$return_string\n"; 
	exit ($exitstate);
	}
}

exit ($exitstate);


#============================ functions ==================================

sub open_session_sec {
	my ($session, $str) = Net::SNMP->session(
		-hostname	=> $o_secondary,
		-community	=> $o_community,
		-port		=> $o_port,
		-timeout	=> $o_timeout
	);
	return $session;
}

sub close_session_sec {
	my ($session) = @_;
	if(defined($session)){
		$session->close;
	}
}

sub open_session_pri {
	my ($session, $str) = Net::SNMP->session(
		-hostname	=> $o_primary,
		-community	=> $o_community,
		-port		=> $o_port,
		-timeout	=> $o_timeout
	);
	return $session;
}

sub close_session_pri {
	my ($session) = @_;

	if(defined($session)){
		$session->close;
	}
}

sub get_ha_status {
	my ($session) = @_;
	my $ha_status;
	my $result = $session->get_request(
		-varbindlist => [$oid_ha_status]
        );

        if (!defined($result)) {
                $return_string = "Error : ".$session->error;
                $state = "UNKNOWN";
		exit 3;
        }
        else {
		$ha_status = $result->{$oid_ha_status};
        }

	return $ha_status;
}

sub get_ha_change {
	my ($session) = @_;
	my $ha_change;

	my $result = $session->get_request(
		-varbindlist => [$oid_ha_change]
        );

        if (!defined($result)) {
                $return_string = "Error : ".$session->error;
                $state = "UNKNOWN";
		exit 3;
        }
        else {
		$ha_change = $result->{$oid_ha_change};
        }

	return $ha_change;
}

sub usage {
	print "Usage: $0 -H <host> [-C <community>] [-p <port>] [-t <timeout>] [-S <secondary] [-V] [-h]\n";
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
	-P, --port=PORT
		SNMP port (Default 161)
	-t, --timeout=INTEGER
		timeout for SNMP (Default 10s)
	-V, --version
		version number
        -S, --secondary
                name or ip of secondary ha member
HELP
}



sub check_options {
	Getopt::Long::Configure("bundling");
	GetOptions(
		'h'	=> \$o_help,		'help'		=> \$o_help,
		'H:s'	=> \$o_primary,		'hostname:s'	=> \$o_primary,
		'P:i'	=> \$o_port,		'port:i'	=> \$o_port,
		'C:s'	=> \$o_community,	'community:s'	=> \$o_community,
		't:i'	=> \$o_timeout,		'timeout:i'	=> \$o_timeout,
		'V'	=> \$o_version,		'version'	=> \$o_version,
		'S=s'	=> \$o_secondary,	'secondary=s'	=> \$o_secondary
	);

	if(defined($o_help)) {
		help(); 
		exit $ERRORS{'UNKNOWN'};
	}

	if(defined($o_version)) {
		version();
		exit $ERRORS{'UNKNOWN'};
	}

	if(!defined($o_primary)) {
		help(); 
		exit $ERRORS{'UNKNOWN'};
	}

}

