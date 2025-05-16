module TestBench
  class Session
    Failure = Class.new(RuntimeError)

    ExecutionBreak = Object.new

    def telemetry
      @telemetry ||= Telemetry::Substitute.build
    end
    attr_writer :telemetry

    def filter_backtrace
      @filter_backtrace ||= Exception::FilterBacktrace::Substitute.build
    end
    attr_writer :filter_backtrace

    def isolate
      @isolate ||= Isolate::Substitute.build
    end
    attr_writer :isolate

    def status
      @status ||= Status.initial
    end
    attr_writer :status

    def trace
      @trace ||= Trace.new
    end
    attr_writer :trace

    def assertion_sequence
      @assertion_sequence ||= 0
    end
    attr_writer :assertion_sequence

    def self.build
      instance = new

      Telemetry.configure(instance)
      Exception::FilterBacktrace.configure(instance)
      Isolate.configure(instance)

      instance
    end

    def self.instance
      @instance ||= build
    end

    def self.configure(receiver, session: nil, attr_name: nil)
      session ||= instance
      attr_name ||= :session

      receiver.public_send(:"#{attr_name}=", session)
    end

    def self.establish(session)
      @instance = session
    end

    def self.register_telemetry_sink(telemetry_sink)
      instance.register_telemetry_sink(telemetry_sink)
    end

    def assert(value)
      self.assertion_sequence += 1

      if value == true
      elsif value == false
        raise Failure, "Assertion failed"
      else
        raise Failure, "Assertion given non-boolean value: #{value.inspect}"
      end
    end

    def comment(text, disposition=nil)
      record_event(Events::Commented.build(text, disposition))
    end

    def detail(text, disposition=nil)
      record_event(Events::Detailed.build(text, disposition))
    end

    def test(title=nil, &block)
      record_event(Events::TestStarted.build(title))

      pending_test_finished_event = Events::TestFinished.build(title)

      evaluate(pending_test_finished_event) do
        previous_sequence = self.assertion_sequence

        block.()

        if self.assertion_sequence == previous_sequence
          raise Failure, "Test didn't perform an assertion"
        end
      end
    end

    def context(title=nil, &block)
      record_event(Events::ContextStarted.build(title))

      pending_context_finished_event = Events::ContextFinished.build(title)

      evaluate(pending_context_finished_event, &block)
    end

    def skip(message=nil)
      record_event(Events::Skipped.build(message))
    end

    def execute(file_path)
      if file_not_found?(file_path)
        record_event(Events::FileNotFound.build(file_path))
        return
      end

      record_event(Events::FileQueued.build(file_path))

      pended_event = Events::FileExecuted.build(file_path, result)

      evaluate(pended_event) do
        isolate.(file_path) do |event_data|
          record_event(event_data)
        end
      end
    end

    def file_not_found?(file_path)
      !File.exist?(file_path)
    end

    def register_telemetry_sink(telemetry_sink)
      telemetry.register(telemetry_sink)
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

    def update(event_or_event_data)
      case event_or_event_data
      in Telemetry::Event => event

      in Telemetry::EventData => event_data
        event_type = event_data.type
        event_class = Events.const_get(event_type, false)

        event = Telemetry::Event::Import.(event_data, event_class)
      end

      case event
      when Events::ContextStarted, Events::TestStarted
        title = event.title

        if not title.nil?
          trace.push(title)
        end

      when Events::Commented, Events::Detailed
        trace.push(event.text)
      end

      telemetry.record(event)

      status.update(event)

      case event
      when Events::Commented, Events::Detailed
        trace.pop

      when Events::ContextFinished, Events::TestFinished
        title = event.title

        if not title.nil?
          trace.pop
        end
      end
    end
    alias :record_event :update

    def result(previous_status=nil)
      status.result(previous_status)
    end

    def evaluate(pending_event, &block)
      previous_status = status.dup

      catch(ExecutionBreak) do
        block.(self)
      end

    rescue Failure => failure
      message = failure.message
      record_event(Events::Failed.build(message))

    rescue ::Exception => exception
      aborted_recorded = status.error_sequence > previous_status.error_sequence

      if not aborted_recorded
        filter_backtrace.(exception)

        message = exception.detailed_message
        record_event(Events::Aborted.build(message))
      end

      raise

    ensure
      result = status.result(previous_status, pending_event)

      pending_event.result = result
      record_event(pending_event)

      if exception.nil?
        return result
      end
    end
  end
end
