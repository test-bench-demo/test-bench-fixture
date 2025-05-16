module TestBench
  class Output
    class Writer
      def device
        @device ||= Device::Substitute.build
      end
      attr_writer :device

      attr_accessor :styling
      alias :styling? :styling

      def indentation_depth
        @indentation_depth ||= 0
      end
      attr_writer :indentation_depth

      def self.build(styling: nil, device: nil)
        instance = new

        Device.configure(instance, device:)

        device = instance.device

        styling = styling(styling, device)
        instance.styling = styling

        instance
      end

      def self.configure(receiver, styling: nil, device: nil, attr_name: nil)
        attr_name ||= :writer

        instance = build(styling:, device:)
        receiver.public_send(:"#{attr_name}=", instance)
      end

      def self.styling(styling_or_styling_policy, device)
        case styling_or_styling_policy
        in true | false => styling
          return styling
        in :detect | :on | :off => styling_policy
        in nil
          styling_policy = Defaults.styling_policy
        end

        case styling_policy
        in :detect
          device.tty?
        in :on
          true
        in :off
          false
        end
      end

      def indent
        indentation_width = 2 * indentation_depth

        print(' ' * indentation_width)
      end

      def puts(text=nil)
        if not text.nil?
          print(text.chomp)
        end

        style(:reset)

        print("\n")
      end

      def style(style, *additional_styles)
        styles = [style, *additional_styles]

        control_codes = styles.map do |style|
          Style.control_code(style)
        end

        if styling?
          control_sequence = "\e[#{control_codes.join(';')}m"

          print(control_sequence)
        end

        self
      end

      def print(text)
        write(text)

        self
      end

      def write(text)
        device.write(text)
      end

      def increase_indentation
        self.indentation_depth += 1
      end

      def decrease_indentation
        self.indentation_depth -= 1
      end

      module Defaults
        def self.styling_policy
          env_styling_policy = ENV.fetch('TEST_OUTPUT_STYLING', 'detect')

          styling_policy = env_styling_policy.to_sym

          styling_policy
        end
      end
    end
  end
end
