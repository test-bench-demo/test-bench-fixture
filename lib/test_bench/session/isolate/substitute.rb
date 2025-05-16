module TestBench
  class Session
    class Isolate
      module Substitute
        def self.build
          Isolate.new
        end

        class Isolate
          def file_paths
            @file_paths ||= []
          end
          attr_writer :file_paths

          def events
            @events ||= []
          end
          attr_writer :events
          alias :set_events :events=

          attr_accessor :stopped
          def stopped?
            stopped ? true : false
          end

          def call(file_path, &block)
            file_paths << file_path

            events.each(&block)
          end

          def stop
            self.stopped = true
          end

          def executed?(file_path)
            file_paths.include?(file_path)
          end
        end
      end
    end
  end
end
