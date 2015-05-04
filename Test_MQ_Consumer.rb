require "bunny"

conn = Bunny.new
conn.start

if ARGV.empty?
  conn.close
  abort()
else
  queue_name = ARGV.join()
end

ch = conn.create_channel
#need to check if the queue name if existed already
if conn.queue_exists?(queue_name)  
  q = ch.queue(queue_name, :durable => true)
else
  puts "Could not find a queue named: #{queue_name}..."
  conn.close
  abort()
end

# if no prefetch(1), we need to press CTRL+C to Stop running, otherwise all msg will be consumed at once
ch.prefetch(1)
#puts " [*] Waiting for messages. To exit press CTRL+C"

begin
  #First, need to add timeout control and check the queue size--abort when queue is empty
  if q.message_count==0
    puts "queue is empty, exiting!" 
    conn.close
    abort()
  end

  q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
    
    puts "'#{body}'"
    # imitate some work
    sleep 1.0
    ch.ack(delivery_info.delivery_tag)
    delivery_info.consumer.cancel

  end
rescue Interrupt => _
  conn.close
end
