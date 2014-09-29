require "bunny"

conn = Bunny.new
conn.start

if ARGV.empty?
  conn.close
  puts 'No queue name defined, exiting!'
  abort()
else
  msg = ARGV
end

#msg format example: queue_name listingID:123456 eventID:123456
queue_name = msg.shift
if msg.empty?
  conn.close
  puts 'No detail msg defined, exiting!'
  abort()
else
  msg = msg.join('|')
end

ch   = conn.create_channel

q = ch.queue(queue_name, :durable => true)

# fill in the queue
q.publish(msg, :persistent => true)
puts "#{msg}"

sleep 1.0
conn.close