module TestBench
  module Test
    class Session
      module Events
        def self.each_type(&block)
          constants(false).each(&block)
        end

        Failed = Test::Telemetry::Event.define(:message)

        ContextStarted = Test::Telemetry::Event.define(:title)
        ContextFinished = Test::Telemetry::Event.define(:title, :result)
        ContextSkipped = Test::Telemetry::Event.define(:title)

        TestStarted = Test::Telemetry::Event.define(:title)
        TestFinished = Test::Telemetry::Event.define(:title, :result)
        TestSkipped = Test::Telemetry::Event.define(:title)

        Commented = Test::Telemetry::Event.define(:text, :heading, :indent_style)
        Detailed = Test::Telemetry::Event.define(:text, :heading, :indent_style)

        FixtureStarted = Test::Telemetry::Event.define(:name)
        FixtureFinished = Test::Telemetry::Event.define(:name, :result)
      end
    end
  end
end
