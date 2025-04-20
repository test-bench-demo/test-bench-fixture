module TestBench
  module Test
    module Automated
      class Output
        class Device
          class Null
            def self.instance
              @instance ||= new
            end

            def write(data)
              data.bytesize
            end

            def tty?
              false
            end

            def sync
              true
            end

            def sync=(_sync)
            end
          end
        end
      end
    end
  end
end
