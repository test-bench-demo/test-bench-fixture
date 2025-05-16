module TestBench
  class Session
    module Exception
      class FilterBacktrace
        def patterns
          @patterns ||= []
        end
        attr_writer :patterns

        attr_accessor :styling
        alias :styling? :styling

        def self.build
          instance = new

          patterns = Defaults.patterns
          instance.patterns = patterns

          styling = Defaults.styling
          instance.styling = styling

          instance
        end

        def self.configure(receiver, attr_name: nil)
          attr_name ||= :filter_backtrace

          instance = build
          receiver.public_send(:"#{attr_name}=", instance)
        end

        def call(exception)
          if styling?
            omitted_text = "\e[2;3m*omitted*\e[23;22m"
          else
            omitted_text = "*omitted*"
          end

          backtrace = []

          original_frame = exception.backtrace_locations.first.to_s
          backtrace << original_frame

          filtering = false

          exception.backtrace_locations[1..-1].each do |backtrace_location|
            backtrace_path = backtrace_location.path

            matches_pattern = patterns.any? do |pattern|
              ::File.fnmatch?(pattern, backtrace_path)
            end

            if matches_pattern
              if not filtering
                backtrace << omitted_text
              end

              filtering = true
            else
              filtering = false
            end

            if not filtering
              backtrace << backtrace_location.to_s
            end
          end

          exception.set_backtrace(backtrace)

          if exception.cause
            self.(exception.cause)
          end
        end

        module Defaults
          def self.patterns
            env_filter_backtrace_patterns = ENV.fetch('TEST_FILTER_BACKTRACE_PATTERNS', '')

            env_filter_backtrace_patterns.split(':')
          end

          def self.styling
            ::Exception.to_tty?
          end
        end
      end
    end
  end
end
