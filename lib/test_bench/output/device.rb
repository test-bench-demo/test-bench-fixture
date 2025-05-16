module TestBench
  class Output
    class Device
      Error = Class.new(RuntimeError)

      def raw_device
        @raw_device ||= Substitute.build
      end
      attr_writer :raw_device

      def self.build(target_device=nil)
        target_device ||= Defaults.target_device

        raw_device = raw_device(target_device)

        instance = new
        instance.raw_device = raw_device
        instance
      end

      def self.configure(receiver, device: nil, attr_name: nil)
        attr_name ||= :device

        if device.instance_of?(self)
          instance = device
        else
          target_device = device

          instance = build(target_device)
        end

        receiver.public_send(:"#{attr_name}=", instance)
      end

      def self.raw_device(target_device)
        case target_device
        in :stdout
          STDOUT
        in :stderr
          STDERR
        in :null
          Null.instance
        in Symbol
          raise Error, "Incorrect output device: #{target_device.inspect}"
        else
          target_device
        end
      end

      def write(text)
        raw_device.write(text)

        text.bytesize
      end

      def tty?
        raw_device.tty?
      end

      module Defaults
        def self.target_device
          env_target_device = ENV.fetch('TEST_OUTPUT_DEVICE') do
            STDOUT.sync = true

            'stdout'
          end

          env_target_device.to_sym
        end
      end
    end
  end
end
