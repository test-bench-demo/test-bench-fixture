module TestBench
  module Test
    module Automated
      class Output
        class Writer
          Error = Class.new(RuntimeError)

          def device
            @device ||= Device::Substitute.build
          end
          attr_writer :device

          attr_accessor :original_device
          alias :set_original_device :original_device=

          attr_accessor :buffering
          def buffering?
            buffering ? true : false
          end

          def buffered_text
            @buffered_text ||= String.new
          end
          attr_writer :buffered_text

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

          def restore
            if not detached?
              raise Error, "Not detached"
            end

            self.device = original_device
            self.original_device = nil

            disable_buffering
          end

          def detach(enable_buffering=nil)
            enable_buffering ||= false

            if detached?
              raise Error, "Already detached"
            end

            self.original_device = device
            self.device = Device::Null.instance

            if enable_buffering
              self.enable_buffering
            end
          end

          def detached?
            not original_device.nil?
          end

          def write(text)
            if buffering?
              buffered_text << text
            else
              write!(text)
            end
          end

          def enable_buffering
            self.buffering = true
          end

          def disable_buffering
            self.buffering = false

            write!(buffered_text)

            buffered_text.clear
          end

          def write!(text)
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
  end
end
