#!/usr/bin/perl

use strict;

use warnings;

use LWP::UserAgent;

use JSON;

use File::Slurp;

use URI::Escape;

use Data::Dumper;

my $bot_token = 'YOUR_BOT_TOKEN_HERE';

my $base_url = 'https://discord.com/api/v6';

# Set up LWP user agent

my $ua = LWP::UserAgent->new;

$ua->default_header(Authorization => "Bot $bot_token");

# Set up JSON

my $json = JSON->new;

$json->pretty(1);

$json->canonical(1);

while (1) {

  # Poll for new messages

  my $response = $ua->get("$base_url/channels/{channel.id}/messages?limit=1");

  if ($response->is_success) {

    my $data = $json->decode($response->decoded_content);

    my $message = $data->{'0'};

    if ($message) {

      # Check if the message starts with !play

      if ($message->{'content'} =~ /^!play (.*)$/) {

        my $query = uri_escape($1);

        # Search YouTube for the query

        my $search_response = $ua->get("https://www.googleapis.com/youtube/v3/search?part=id&type=video&q=$query&key=YOUR_YOUTUBE_API_KEY");

        if ($search_response->is_success) {

          my $search_data = $json->decode($search_response->decoded_content);

          my $video_id = $search_data->{'items'}->[0]->{'id'}->{'videoId'};

          # Send the video to the channel

          my $send_response = $ua->post("$base_url/channels/{channel.id}/messages", {

            'content' => "https://www.youtube.com/watch?v=$video_id"

          });

          if ($send_response->is_success) {

            print "Sent video to channel\n";

          } else {

            print "Failed to send video to channel\n";

          }

        } else {

          print "Failed to search YouTube\n";

        }

      } elsif ($message->{'content'} eq '!pause') {

        # Pause the current song

        print "Paused song\n";

      } elsif ($message

