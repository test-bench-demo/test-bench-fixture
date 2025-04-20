module TestBench
  module Test
    module Automated
      class Session
        module Events
          Failed = Telemetry::Event.define(:message)
          Aborted = Telemetry::Event.define(:message)
          Skipped = Telemetry::Event.define(:message)

          Commented = Telemetry::Event.define(:text, :disposition)
          Detailed = Telemetry::Event.define(:text, :disposition)

          TestStarted = Telemetry::Event.define(:title)
          TestFinished = Telemetry::Event.define(:title, :result)

          ContextStarted = Telemetry::Event.define(:title)
          ContextFinished = Telemetry::Event.define(:title, :result)

          FileQueued = Telemetry::Event.define(:file)
          FileExecuted = Telemetry::Event.define(:file, :result)
          FileNotFound = Telemetry::Event.define(:file)
        end
      end
    end
  end
end
