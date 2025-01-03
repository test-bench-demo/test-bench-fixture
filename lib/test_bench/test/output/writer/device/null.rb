module TestBench
  module Test
    module Output
      class Writer
        module Device
          class Null
            def self.build
              @instance ||= new
            end

            def write(data)
              data.bytesize
            end

            def tty?
              false
            end
          end
        end
      end
    end
  end
end
