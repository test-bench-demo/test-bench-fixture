module TestBench
  module Test
    module Automated
      class Telemetry
        module Sink
          class File
            include Sink

            attr_reader :file

            def initialize(file)
              @file = file
            end

            def self.build(file_path)
              file = ::File.open(file_path, 'w')

              new(file)
            end

            def self.open(file_path, &block)
              ::File.open(file_path, 'w') do |file|
                instance = new(file)

                block.(instance, file)

                return instance
              end
            end

            def receive(event_data)
              text = event_data.dump

              file.write(text)
            end
          end
        end
      end
    end
  end
end
