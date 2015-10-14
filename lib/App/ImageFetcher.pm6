use v6;
unit class App::ImageFetcher;

use HTTP::Tinyish;

has HTTP::Tinyish $.agent;

method new() {
    my $agent = HTTP::Tinyish.new;
    self.bless(:$agent);
}

method fetch(Str:D $url) returns Bool:D {
    my %res = $.agent.get($url);
    unless %res<success> {
        return False;
    }

    my $content = %res<content>;
    my $re = rx/src\='"'(<-["]>+)'"'/;
    for $content.match($re, :overlap) -> $m  {
        my $link = $m.caps[0].value;
        next unless $link ~~ /(\.jpe?g|png)$$/;
        next unless $link ~~ /^^http\:\/\//;

        my %r = $.agent.get($link.Str, :bin);
        unless %r<success> {
            warn "Download failed:", $link.Str, "\n";
            return False;
        }

        my $file = $link.IO.basename;
        my $fh = open $file, :w or return False;
        say "Write out: $file";
        $fh.write(%r<content>);
        $fh.close;
    }

    return True;
}

=begin pod

=head1 NAME

App::ImageFetcher - Simple images fetcher

=head1 SYNOPSIS

  use App::ImageFetcher;

  my $app = $app::ImageFetcher.new;
  $app.fetch($some_url);

=head1 DESCRIPTION

App::ImageFetcher is a simple image fetcher.

=head1 AUTHOR

Syohei YOSHIDA <syohex@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Syohei YOSHIDA

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
