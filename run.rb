#!/usr/bin/ruby
require 'optparse'
require 'pathname'
require 'yaml'

options = {}
options[:gen] = false
if !ARGV or ARGV.length == 0 then
    ARGV << "-h"
end
OptionParser.new do |opts|
    opts.banner = "Usage: run.rb [options]"

    opts.on('-g', '--generate', 'Generate default config') { |v| options[:gen] = true }
    opts.on('-c', '--config CONFIG', 'Use config CONFIG') { |v| options[:config] = v }
    opts.on('-h', '--help', 'Show this message') { puts opts }
    opts.parse!
end
@DEFAULT_YAML = {
    'ff_profile'        => 'example',
    'ff_profile_dir'    => 'et9az2vp.example',
    'ff_wait'           => 42,
    'ff_url'            => 'http://ingress.com/intel?ll=49.88,10.90&z=14',
    'xvfb_res_width'    => 1920,
    'xvfb_res_height'   => 1080,
    'xvfb_display'      => 23,
    'ss_width'          => 1280,
    'ss_height'         => 720,
    'ss_offset_left'    => 220,
    'ss_offset_top'     => 220,
    'timestamp'         => false,
    'interval' => {
        '1000' => 600,
        '1100' => 300,
        '1145' => 60,
        '1215' => 300,
        '1300' => "end"
    }
}

if options[:gen] then
    File.open('default.cfg', 'w') {|f| f.write YAML.dump(@DEFAULT_YAML)}
    `cat default.cfg`
    exit
end

__END__
die if ARGV.length != 1
path = Pathname.new(ARGV[0])
if !path.exist? then
    puts "Error: config file does not exist\n\n"
    die
elsif !path.readable? then
    puts "Error: config file not readable\n\n"
    die
end

