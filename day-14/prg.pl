use 5.010;
use strict;
use warnings FATAL => 'all';

sub base_from {
    my ($n) = @_;
    my $t = 0;
    for my $c (split(//, $n)) {
        $t = 2 * $t + index("01", $c);
    }
    $t;
}

sub process {
    my ($file_name, $mod_addr, $mod_val) = @_;

    my %mem = ();
    my $mask = 0;

    open my $file, $file_name or die "Could not open $file_name: $!";

    while (my $line = <$file>) {
        if ($line =~ /mem\[(\d+)\] = (\d+)/) {
            my $addr = $1;
            my $val = $2;
            # say("$addr = $val");

            my $v = $mod_val->($val, $mask);
            foreach my $a ($mod_addr->($addr, $mask)) {
                $mem{$a} = $v;
                # say("\t$a = $v");
            }
        }
        elsif ($line =~ /mask = (.*)/) {
            $mask = $1;
            # say($mask)
        }
        else {
            die("Unknown line format $line");
        }
    }

    close($file);

    %mem;
}

sub sum_mem {
    my %mem = @_;
    my $sum = 0;
    foreach my $val (values %mem) {
        $sum += $val;
    }
    say($sum);
}

my $file_name = $ARGV[0];

sub get_addr {
    my ($addr, $mask, $i, $addrs) = @_;
    if ($i == length($mask)) {
        push @{$addrs}, $addr
    }
    else {
        my $m = substr($mask, $i, 1);
        my $b = 1 << $i;
        if ($m ne '0') {
            if ($m ne '1') {
                $addr &= ~$b;
                get_addr($addr, $mask, $i + 1, $addrs);
            }
            $addr |= $b;
        }
        get_addr($addr, $mask, $i + 1, $addrs);
    }
}

sum_mem(process($file_name, sub {
    my ($addr, $mask) = @_;
    ($addr,)
}, sub {
    my ($val, $mask) = @_;
    my $mask1 = base_from($mask =~ tr/X01/001/r);
    my $mask0 = base_from($mask =~ tr/X01/010/r);
    ($val | $mask1) & ~$mask0;
}));

sum_mem(process($file_name, sub {
    my ($addr, $mask) = @_;
    my @addrs = ();
    get_addr($addr, scalar reverse($mask), 0, \@addrs);
    @addrs;
}, sub {
    my ($val, $mask) = @_;
    $val;
}));
