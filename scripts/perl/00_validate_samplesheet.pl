#!/usr/bin/env perl
use strict;
use warnings;

my $file = shift or die "Usage: $0 <samplesheet.tsv>\n";

open(my $fh, "<", $file) or die "Cannot open $file\n";

my $header = <$fh>;
defined $header or die "Empty input file: $file\n";
chomp $header;

my @expected = qw(srr sample_id condition replicate);
my @cols = split /\t/, $header, -1;

if (join(",", @cols) ne join(",", @expected)) {
    die "Invalid header.\nExpected: @expected\nGot: @cols\n";
}

my %seen_sample;
my %seen_srr;
my $line_num = 1;

while (my $line = <$fh>) {
    $line_num++;
    chomp $line;
    next if $line =~ /^\s*$/;

    my @fields = split /\t/, $line, -1;

    if (@fields != 4) {
        die "Line $line_num: expected 4 columns\n";
    }

    my ($srr, $sample_id, $condition, $replicate) = @fields;

    die "Line $line_num: invalid SRR accession\n"
        unless defined $srr && $srr =~ /^SRR\d+$/;

    die "Line $line_num: invalid sample_id\n"
        unless defined $sample_id && $sample_id =~ /^[A-Za-z0-9_.-]+$/;

    die "Line $line_num: condition cannot be empty\n"
        unless defined $condition && $condition ne "";

    die "Line $line_num: replicate must be numeric\n"
        unless defined $replicate && $replicate =~ /^\d+$/;

    die "Duplicate sample_id: $sample_id\n"
        if exists $seen_sample{$sample_id};

    die "Duplicate srr: $srr\n"
        if exists $seen_srr{$srr};

    $seen_sample{$sample_id} = 1;
    $seen_srr{$srr} = 1;
}

close $fh;

print "Input samplesheet validation: OK\n";
