#!/usr/bin/ruby
require 'optparse'
require 'pathname'
require 'yaml'
require 'date'

options = {}
options[:gen] = false
if !ARGV or ARGV.length == 0 then
    ARGV << "-h"
end
opts = OptionParser.new do |opts|
    opts.banner = "Usage: run.rb [options]"

    opts.on('-g', '--generate', 'Generate default config') { |v| options[:gen] = true }
    opts.on('-c', '--config CONFIG', 'Use config CONFIG') { |v| options[:config] = v }
    opts.on('-h', '--help', 'Show this message') { puts opts; exit }
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

cfg = {}
if options[:gen] then
    File.open('default.cfg', 'w') {|f| f.write YAML.dump(@DEFAULT_YAML)}
    exit
else
    if not options[:config] then
        puts opts
        exit
    end
    path = Pathname.new(options[:config])
    if !path.exist? then
        puts "Error: config file does not exist\n\n"
        exit(1)
    elsif !path.readable? then
        puts "Error: config file not readable\n\n"
        exit(1)
    end

    cfg = YAML.load_file(options[:config])
end
if cfg.empty? then
    puts "Error processing config file"
    exit(1)
end

puts "Starting XVFB on #{cfg['xvfb_display']}"
`Xvfb :#{cfg['xvfb_display']} -screen 0 #{cfg['xvfb_res_width']}x#{cfg['xvfb_res_height']}x24 -noreset -nolisten tcp 2> /dev/null &`
xvfb_pid = $?.pid

def add_timestamp(name)
    xtext=`expr #{ss_width} - 50`
    ytext=`expr #{ss_height} + 175`
    date=`date +"%d-%m-%Y %H:%M:%S"`
    stext="text #{xtext},#{ytext} '#{date}'"
    `convert -pointsize 20 -fill yellow -draw "#{stext}" #{name} #{name}`
end

#wait for start time
delay= cfg['interval'].values[0]
zone = DateTime.now.strftime('%z')
left = DateTime.strptime("#{cfg['interval'].keys[0]} #{zone}",'%H%M %z') - DateTime.now
left = 1+left if left < 0
left = (left * 24 * 60 * 60).to_i
while left > 0 do
    p "\rWaiting for #{left} seconds...                "
    left -= 5
    sleep 5
end


timeindex = 1
loop do
    `rm ~/.mozilla/firefox/#{cfg['ff_profile_dir']}/.parentlock`

    puts "Running firefox -P #{cfg['ff_profile']} on #{cfg['xvfb_display']}"
    `:#{cfg['xvfb_display']} firefox -P #{cfg['ff_profile']} -width #{cfg['xvfb_res_width']} -height #{cfg['xvfb_res_height']} "#{cfg['ff_url']}" > /dev/null &`
    ff_pid = $?.pid

    puts "Firefox running on pid #{ff_pid}, waiting #{cfg['ff_wait']} seconds"
    sleep(cfg['ff_wait'])

    ham_date = `date +"%Y-%m-%d_%H-%M-%S"`
    puts "Taking screenshot: #{ham_date}"
    `:#{cfg['xvfb_display']} import -window root -crop #{cfg['ss_width']}x#{cfg['ss_height']}+#{cfg['ss_offset_left']}+#{cfg['ss_offset_top']} "ingr-#{ham_date}.png"`
    add_timestamp "ingr-#{ham_date}.png" if cfg['timestamp']

    puts "Killing firefox on PID #{ff_pid}"
    `kill #{ff_pid}`

    if DateTime.strptime("#{cfg['interval'].keys[timeindex]} #{zone}",'%H%M %z') - DateTime.now < 0 then
        timeindex += 1
        delay = cfg['interval'].values[timeindex]
    end
    if delay == "end" then
        puts "Completed"
        break
    end

    puts "Waiting #{delay} for next screenshot"
    sleep(delay)
end

puts "Killing XVFB on #{xvfb_pid}"
`kill #{xvfb_pid}`
