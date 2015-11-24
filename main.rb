require 'eventmachine'
require 'pry'

module KukaServer
  def initialize(*args)
    super(args)

    @@send_msg = Proc.new do |data|

      # point = {
      #   X: 491.555,
      #   Y: -374.72,
      #   Z: 711,
      #   A: 34.076,
      #   B: 20.657,
      #   C: 95.829
      # }
      point = {
        X: rand(200.0..400.0).round(3) * (rand(0..1)==1 ? 1 : -1),
        Y: rand(200.0..400.0).round(3) * (rand(0..1)==1 ? 1 : -1),
        Z: rand(300.0..800.0).round(3),
        A: '',#rand(10.0..90.0).round(3),
        B: '',#rand(10.0..90.0).round(3),
        C: ''#rand(10.0..90.0).round(3) * (rand(0..1)==1 ? 1 : -1)
      }

      buffer = point.map { |key, value| "#{key}=\"#{value}\"" }.join(' ')

      msg = "<Buffer><Point #{buffer}/></Buffer>"
      send_data msg
      puts "-- sent \"#{msg}\""
    end
  end

  def post_init
    puts "-- Kuka connected to server"
    EventMachine.open_keyboard(KeyboardHandler)
    puts '-- Waiting for input'
    print '> '
  end

  def unbind
    puts "-- Kuka disconnected from server"
  end
end

module KeyboardHandler
  def receive_data keys
    keys.strip!

    unless keys.empty?
      case keys
      when 'q'
        puts "-- Shutting Kuka server down"
        close_connection
        EventMachine.stop
      else
        puts "-- Sending '#{keys}' to Kuka"
        KukaServer.class_variable_get(:@@send_msg).call(keys)
        puts '-- Waiting for input'
        print '> '
      end
    end
  end
end

class Echo < EventMachine::Connection
  def post_init
    # send_data 'Hello'
  end

  def receive_data(data)
    puts "-- received #{data}"
  end
end

# -------------------------------------

EventMachine.run {
  EventMachine.start_server '172.31.1.205', 50000, KukaServer
  puts '-- Kuka server started'
  # EventMachine::connect '172.31.1.205', 50000, Echo
}
