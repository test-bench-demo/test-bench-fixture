module TestBench
  module Test
    module Automated
      class Session
        module Result
          extend self

          def self.resolve(result, strict: nil)
            strict ||= Defaults.strict

            case result
            in "passed"
              true
            in "failed" | "aborted"
              false
            in "none" | "incomplete"
              !strict
            end
          end

          def passed
            "passed"
          end

          def failed
            "failed"
          end

          def none
            "none"
          end

          def aborted
            "aborted"
          end

          def incomplete
            "incomplete"
          end
        end
      end
    end
  end
end
