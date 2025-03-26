module TestBench
  module Test
    class Session
      class Output
        module Detail
          Error = Class.new(RuntimeError)

          def self.detail?(policy, mode)
            assure_detail(policy, mode)
          end

          def self.assure_detail(policy, mode=nil)
            mode ||= Mode.initial

            case policy
            when on
              true
            when off
              false
            when failure
              if mode == Mode.failing || mode == Mode.initial
                true
              else
                false
              end
            else
              raise Error, "Unknown detail policy #{policy.inspect}"
            end
          end

          def self.on
            :on
          end

          def self.off
            :off
          end

          def self.failure
            :failure
          end

          def self.default
            policy = ENV.fetch('TEST_DETAIL') do
              return failure
            end

            policy.to_sym
          end
        end
      end
    end
  end
end
