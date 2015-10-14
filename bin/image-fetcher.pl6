#!/usr/bin/env perl6
use v6;
use App::ImageFetcher;

sub MAIN(*@urls) {
    my $app = App::ImageFetcher.new;
    for @urls -> Str $url {
        my $ret = $app.fetch($url);
        if (!$ret) {
            die "Download failed: '$url'";
        }
    }
}
