#!/usr/local/bin/perl

use strict;


use PerlIO::gzip;

my @files = grep { /\.gz$/ } @ARGV;
my %mailblurb = ();
my %count_discarded_record = ();

foreach my $current_file ( @files ) {
        print "Procesing file $current_file:\n";

        my %associations = ();
        my ( $icidValue, $midValue );
        my $line;       

        # make sure we're working with a log file
        open FOO, "<:gzip", $current_file or die $!;
        $line = <FOO>;
        print $line;
        my ( $start_datestamp ) = $line =~ /((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{1,2} \d{2}:\d{2}:\d{2}) /;
        die "Can't find timestamp on first line of file:  ABORT.  Line=$line.\n" if ( ! defined $start_datestamp );

        print "Start date = $start_datestamp\n";
        close FOO;
        

        open FOO, "<:gzip", $current_file or die $!;
        
        while ( <FOO> ) { 

                $line = $_;

                # reset for each new record
                $icidValue = $midValue = '';

                # we need to track all records, since what we're looking for may match later.
                # make the association between ICID value and MID value, because some records only have a MID
                if ( / ICID (\d{1,12}) / ) {
                        $icidValue = $1;        
                }
                if ( / MID (\d{1,12}) / ) {
                        $midValue = $1;
                        if ( $icidValue != '' ) {
                                if ( defined $associations{ $midValue } ) { 
                                        die "Logic error" if ( $associations{ $midValue } != $icidValue );
                                }
                                print "Associating $icidValue with the MID value of $midValue.\n";
                                #$associations{ $icidValue } = $midValue;
                                $associations{ $midValue } = $icidValue;
                        }
                }

                # if we don't have a icidValue, then we need to check for an association.
                if ( $icidValue == '' ) {
                        if ( ! defined $associations{ $midValue } ) {
                                $count_discarded_record{ $current_file }++;
                                warn "$.: Discarding record: no association found for \"$midValue\". Record=" . substr( $_, 0, 80 ) . ( ( $_[-1] eq "\n" ) ? '' : "\n" ) ;
                        }
                }
                
                $mailblurb{ $icidValue } .= $_;

                # determine if it's what we're looking for
                if ( /linkedin.com/ ) {
                        print "  ${current_file}: $_";
                }
        }
        print "Last line = $line";
        my ( $end_datestamp ) = $line =~ /((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{1,2} \d{2}:\d{2}:\d{2}) /;

        print "\n\n\n$. records processed in $current_file, $count_discarded_record{$current_file} records discarded.\n";
        print "    Starting datestamp = $start_datestamp,   Ending datestamp = $end_datestamp.\n";
        close FOO;
}




__END__

This is what one record should look like:




sun:10:49am[root@Leibniz]ironport as root#  egrep ' 69610481 | 38637862 ' test
Jun 26 10:42:23 ip1out.temple.edu mail_logs: Info: New SMTP ICID 69610481 interface IP-Inbound (155.247.167.43) address 199.101.162.90 reverse dns host maile-fb.linkedin.com verifi
ed yes
Jun 26 10:42:23 ip1out.temple.edu mail_logs: Info: ICID 69610481 ACCEPT SG VALIDLIST match sbrs[2.0:10.0] SBRS 5.5
Jun 26 10:42:23 ip1out.temple.edu mail_logs: Info: Start MID 38637862 ICID 69610481
Jun 26 10:42:23 ip1out.temple.edu mail_logs: Info: MID 38637862 ICID 69610481 From: <m-XCzcfqOcRIvdTvkIgwORlvuOZnddGLH9o2FNfIr-0wuloddlSdmgfpHcyvlzFx@bounce.linkedin.com>
Jun 26 10:42:23 ip1out.temple.edu mail_logs: Info: MID 38637862 ICID 69610481 RID 0 To: <thomas.force@temple.edu>
Jun 26 10:42:24 ip1out.temple.edu mail_logs: Info: MID 38637862 Message-ID '<1177218344.458080.1372257743385.JavaMail.app@ela4-app2321.prod>'
Jun 26 10:42:24 ip1out.temple.edu mail_logs: Info: MID 38637862 Subject 'Your connection Nancie Jordan has endorsed you!'
Jun 26 10:42:24 ip1out.temple.edu mail_logs: Info: MID 38637862 ready 14453 bytes from <m-XCzcfqOcRIvdTvkIgwORlvuOZnddGLH9o2FNfIr-0wuloddlSdmgfpHcyvlzFx@bounce.linkedin.com>
Jun 26 10:42:24 ip1out.temple.edu mail_logs: Info: MID 38637862 rewritten to MID 38637865 by LDAP rewrite
Jun 26 10:42:24 ip1out.temple.edu mail_logs: Info: LDAP: Reroute query ChainRoute MID 38637862 RID 0 address thomas.force@temple.edu to [('tue58286@gomail.temple.edu', '')]
Jun 26 10:42:24 ip1out.temple.edu mail_logs: Info: Message finished MID 38637862 done
Jun 26 10:42:29 ip1out.temple.edu mail_logs: Info: ICID 69610481 close
sun:10:49am[root@Leibniz]ironport as root#  
