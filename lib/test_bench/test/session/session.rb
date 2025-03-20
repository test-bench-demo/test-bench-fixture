module TestBench
  module Test
    class Session
      Failure = Class.new(RuntimeError)
      Abort = Class.new(Failure)

      Error = Class.new(RuntimeError)

      def telemetry
        @telemetry ||= Test::Telemetry::Substitute.build
      end
      attr_writer :telemetry

      def failure_sequence
        @failure_sequence ||= 0
      end
      attr_writer :failure_sequence

      def assertion_sequence
        @assertion_sequence ||= 0
      end
      attr_writer :assertion_sequence

      def skip_sequence
        @skip_sequence ||= 0
      end
      attr_writer :skip_sequence

      def self.build(&block)
        block ||= proc { |telemetry|
          Output.register(telemetry)
        }

        instance = new

        Test::Telemetry.configure(instance)

        telemetry = instance.telemetry
        block.(telemetry)

        instance
      end

      def self.instance
        @instance ||= build
      end
      singleton_class.attr_writer :instance

      def self.reestablish(&block)
        if @instance.nil?
          raise Error, "Session hasn't been established"
        end

        self.instance = build(&block)
      end

      def self.configure(receiver, session: nil, attr_name: nil)
        session ||= instance
        attr_name ||= :session

        instance = session
        receiver.public_send(:"#{attr_name}=", instance)
      end

      def inspect(raw: nil)
        if raw
          return super()
        end

        telemetry_placeholder = Struct.new(:inspect).new("(not inspected)")

        original_telemetry = self.telemetry

        self.telemetry = telemetry_placeholder

        begin
          super()

        ensure
          self.telemetry = original_telemetry
        end
      end

      def passed?
        if failed?
          false
        elsif not skipped?
          true
        else
          Session.unknown_result
        end
      end

      def fixture(name, &block)
        original_failure_sequence = failure_sequence

        record_event(Events::FixtureStarted.new(name))

        begin
          block.()

        rescue Failure

        ensure
          result = !failed?(original_failure_sequence)

          record_event(Events::FixtureFinished.new(name, result))
        end

        result
      end

      def detail(text, indent_style=nil, heading=nil)
        indent_style ||= Output::IndentStyle.get(text, heading, indent_style)

        record_event(Events::Detailed.new(text, heading, indent_style))
      end

      def comment(text, indent_style=nil, heading=nil)
        indent_style ||= Output::IndentStyle.get(text, heading, indent_style)

        record_event(Events::Commented.new(text, heading, indent_style))
      end

      def context!(...)
        if context(...) == false
          message = Session.abort_message
          raise Abort, message
        end
      end

      def context(title=nil, &block)
        if block.nil?
          record_event(Events::ContextSkipped.new(title))
          return
        end

        original_failure_sequence = failure_sequence

        record_event(Events::ContextStarted.new(title))

        begin
          block.()

        rescue Failure

        ensure
          result = !failed?(original_failure_sequence)

          record_event(Events::ContextFinished.new(title, result))
        end

        result
      end

      def test!(...)
        if test(...) == false
          message = Session.abort_message
          raise Abort, message
        end
      end

      def test(title=nil, &block)
        if block.nil?
          record_event(Events::TestSkipped.new(title))
          return
        end

        original_failure_sequence = failure_sequence
        original_assertion_sequence = assertion_sequence

        record_event(Events::TestStarted.new(title))

        begin
          block.()

          result = !failed?(original_failure_sequence)

          if result
            if not asserted?(original_assertion_sequence)
              failure_message = Session.no_assertion_message
              fail(failure_message)
            end
          end

        rescue Failure
          result = false

        ensure
          record_event(Events::TestFinished.new(title, result))
        end

        result
      end

      def assert(result)
        failure_message = Session.assertion_failure_message

        record_assertion

        if result == false
          fail(failure_message)
        end
      end

      def fail(message=nil)
        message ||= self.class.default_failure_message

        record_event(Events::Failed.new(message))

        raise Failure, message
      end

      def asserted?(compare_sequence=nil)
        compare_sequence ||= 0

        compare_sequence != assertion_sequence
      end

      def register_telemetry_sink(telemetry_sink)
        telemetry.register(telemetry_sink)
      end

      def record_assertion
        self.assertion_sequence += 1
      end

      def failed?(compare_sequence=nil)
        compare_sequence ||= 0

        compare_sequence != failure_sequence
      end

      def record_event(event)
        case event
        when Events::TestSkipped, Events::ContextSkipped
          record_skip
        when Events::Failed
          record_failure
        end

        telemetry.record(event)
      end

      def record_failure
        self.failure_sequence += 1
      end

      def skipped?
        skip_sequence != 0
      end

      def record_skip
        self.skip_sequence += 1
      end

      def self.default_failure_message
        'Failed'
      end

      def self.assertion_failure_message
        "Assertion failed"
      end

      def self.abort_message
        "Abort"
      end

      def self.no_assertion_message
        "Test didn't perform an assertion"
      end

      def self.unknown_result
        nil
      end
    end
  end
end
