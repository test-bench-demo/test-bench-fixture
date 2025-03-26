module TestBench
  module Test
    module Output
      class Writer
        module Styling
          Error = Class.new(RuntimeError)

          def self.styling?(policy, console)
            assure_styling(policy, console)
          end

          def self.assure_styling(policy, console=nil)
            console ||= false

            case policy
            when on
              true
            when off
              false
            when detect
              console ? true : false
            else
              raise Error, "Unknown styling policy #{policy.inspect}"
            end
          end

          def self.on
            :on
          end

          def self.off
            :off
          end

          def self.detect
            :detect
          end

          def self.default
            policy = ENV.fetch('TEST_OUTPUT_STYLING') do
              return detect
            end

            policy.to_sym
          end
        end
      end
    end
  end
end
