#!/usr/bin/env perl
use strict;
use warnings;
use Text::ParseWords qw(parse_line);

my $input   = shift or die "Usage: $0 <samplesheet.tsv> <runinfo.csv> <output.tsv>\n";
my $runinfo = shift or die "Usage: $0 <samplesheet.tsv> <runinfo.csv> <output.tsv>\n";
my $output  = shift or die "Usage: $0 <samplesheet.tsv> <runinfo.csv> <output.tsv>\n";

my %meta_by_srr = load_runinfo_csv($runinfo);

open(my $in,  "<", $input)  or die "Cannot open input file: $input\n";
open(my $out, ">", $output) or die "Cannot open output file: $output\n";

my $header = <$in>;
defined $header or die "Empty input file: $input\n";
chomp $header;

my @expected = qw(srr sample_id condition replicate);
my @cols = split /\t/, $header, -1;

if (join(",", @cols) ne join(",", @expected)) {
    die "Invalid input header in $input\nExpected: @expected\nGot: @cols\n";
}

print $out "sample_id\tcondition\treplicate\tsrr\tbioproject\tlayout\tstrandedness\n";

while (my $line = <$in>) {
    chomp $line;
    next if $line =~ /^\s*$/;

    my ($srr, $sample_id, $condition, $replicate) = split /\t/, $line, -1;

    die "SRR $srr not found in RunInfo file: $runinfo\n"
        unless exists $meta_by_srr{$srr};

    my $bioproject   = $meta_by_srr{$srr}{bioproject};
    my $layout       = $meta_by_srr{$srr}{layout};
    my $strandedness = $meta_by_srr{$srr}{strandedness};

    print $out join(
        "\t",
        $sample_id,
        $condition,
        $replicate,
        $srr,
        $bioproject,
        $layout,
        $strandedness
    ), "\n";
}

close $in;
close $out;

print "Prepared samplesheet written to $output\n";

sub load_runinfo_csv {
    my ($file) = @_;

    open(my $fh, "<", $file) or die "Cannot open runinfo file: $file\n";

    my $header_line = <$fh>;
    defined $header_line or die "Empty runinfo file: $file\n";
    chomp $header_line;

    my @header = parse_line(',', 0, $header_line);
    my %idx;

    for my $i (0 .. $#header) {
        $header[$i] =~ s/^\s+//;
        $header[$i] =~ s/\s+$//;
        $idx{$header[$i]} = $i;
    }

    die "RunInfo file must contain a 'Run' column\n"
        unless exists $idx{"Run"};

    die "RunInfo file must contain a 'BioProject' column\n"
        unless exists $idx{"BioProject"};

    die "RunInfo file must contain a 'LibraryLayout' column\n"
        unless exists $idx{"LibraryLayout"};

    my %map;

    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*$/;

        my @fields = parse_line(',', 0, $line);
        next unless @fields;

        my $run        = $fields[$idx{"Run"}];
        my $bioproject = $fields[$idx{"BioProject"}];
        my $liblayout  = $fields[$idx{"LibraryLayout"}];

        next unless defined $run && $run ne "";
        next unless defined $bioproject && $bioproject ne "";
        next unless defined $liblayout && $liblayout ne "";

        $run        =~ s/^\s+//;
        $run        =~ s/\s+$//;
        $bioproject =~ s/^\s+//;
        $bioproject =~ s/\s+$//;
        $liblayout  =~ s/^\s+//;
        $liblayout  =~ s/\s+$//;

        my $layout = normalize_layout($liblayout);

        $map{$run} = {
            bioproject   => $bioproject,
            layout       => $layout,
            strandedness => "unknown",
        };
    }

    close $fh;
    return %map;
}

sub normalize_layout {
    my ($value) = @_;

    return "PE" if uc($value) eq "PAIRED";
    return "SE" if uc($value) eq "SINGLE";

    return "UNKNOWN";
}
