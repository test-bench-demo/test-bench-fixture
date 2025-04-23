module TestBench
  module Test
    module Automated
      class Output
        class Device
          module Substitute
            def self.build
              Device.new
            end

            class Device
              def written_text
                @written_text ||= String.new
              end
              attr_writer :written_text

              attr_accessor :tty

              def tty?
                tty ? true : false
              end

              def set_tty
                self.tty = true
              end

              def write(text)
                bytes_written = text.bytesize

                written_text << text

                bytes_written
              end

              def written?(text=nil)
                if text.nil?
                  !written_text.empty?
                else
                  written_text == text
                end
              end
            end
          end
        end
      end
    end
  end
end
