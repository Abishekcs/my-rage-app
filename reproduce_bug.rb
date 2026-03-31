# frozen_string_literal: true

require 'bundler/setup'
require 'rage'
Bundler.require(*Rage.groups)
require 'rage/all'
require 'zlib'

puts '=== Reproducing WAL Timestamp Bug ==='
puts ''

# Step 1 - create a future timestamp (simulating previous server run)
future_timestamp = Time.now.to_i + 10_000
puts "Current time:     #{Time.now.to_i}"
puts "Future timestamp: #{future_timestamp}"
puts ''

# Step 2 - build a valid WAL entry with future timestamp
task_id    = "#{future_timestamp}-99999-1"
serialized = Marshal.dump(['SayHello', {}, { name: 'OldTask' }, [], 'req_id', {}]).dump
entry      = "add:#{task_id}:0:#{serialized}"
crc        = Zlib.crc32(entry).to_s(16).rjust(8, '0')
wal_line   = "#{crc}:#{entry}\n"

puts "WAL entry task ID: #{task_id}"
puts ''

# Step 3 - write fake WAL file
storage_path = Pathname.new('storage/bug_repro')
storage_path.mkpath
wal_file = storage_path.join("deferred-0-#{Time.now.strftime('%Y%m%d')}-99999-bugtest")
wal_file.write(wal_line)
puts "Written WAL file: #{wal_file}"
puts ''

# Step 4 - initialize disk backend (reads WAL on boot)
backend = Rage::Deferred::Backends::Disk.new(
  path: storage_path,
  prefix: 'deferred-',
  fsync_frequency: 500
)

# Step 5 - load pending tasks (what server does on boot)
pending = backend.pending_tasks
puts "Pending tasks found: #{pending.length}"
pending.each do |task_id, _task, _publish_at|
  puts "  task_id: #{task_id}"
  puts "  timestamp in WAL: #{task_id.split('-').first}"
end
puts ''

# Step 6 - generate a new task ID
new_task_id = backend.add(
  ['SayHello', {}, { name: 'NewTask' }, [], 'req_id', {}]
)
new_timestamp = new_task_id.split('-').first.to_i
puts "New task ID:        #{new_task_id}"
puts "New timestamp:      #{new_timestamp}"
puts "WAL max timestamp:  #{future_timestamp}"
puts ''

# Step 7 - show the bug
if new_timestamp < future_timestamp
  puts '🔥 BUG REPRODUCED!'
  puts "   New timestamp #{new_timestamp} is LOWER than WAL timestamp #{future_timestamp}"
  puts '   Tasks could have duplicate or out-of-order IDs!'
else
  puts '✅ No bug detected'
  puts "   New timestamp #{new_timestamp} is higher than WAL timestamp #{future_timestamp}"
end

# cleanup
FileUtils.rm_rf(storage_path)
