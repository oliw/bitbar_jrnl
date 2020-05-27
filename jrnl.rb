#!/usr/bin/env ruby

require 'json'

puts "Journal"
puts "---"

HELPER_LIB_DIR = File.join(ENV['HOME'], "BitBar", "jrnl_lib")

count_per_tag = Hash.new

Tag = Struct.new(:name, :count)

def get_entries_for_tag(tag)
  raw_json = `/usr/local/bin/jrnl -n 10 -and #{tag.name} --export json`
  result = JSON.parse(raw_json)
  entries = result["entries"]
  entries = entries.reverse
  entries.map do |entry|
    title = entry["title"]
    title.split(" ").reject{|word| word.start_with?('@')}.join(" ")
  end
end

tags = `/usr/local/bin/jrnl --tags`.split("\n").map do |line|
  parts = line.split(':')
  tag = parts[0].strip
  count = parts[1].strip.to_i
  Tag.new(tag, count)
end

tags = tags.sort_by(&:count).reverse

tags.each do |tag|
  puts "#{tag.name} (x#{tag.count})|bash=/usr/bin/osascript param1=#{File.join(HELPER_LIB_DIR, 'jrnl_prompter.scpt')} param2=#{tag.name} refresh=true terminal=false"
  recent_entries = get_entries_for_tag(tag)
  recent_entries.each do |entry|
    puts "--#{entry}"
  end
end
