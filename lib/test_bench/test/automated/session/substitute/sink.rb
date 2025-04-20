module TestBench
  module Test
    module Automated
      class Session
        module Substitute
          class Sink
            include Telemetry::Sink

            def trace
              @trace ||= Trace.new
            end
            attr_writer :trace

            def records
              @records ||= []
            end
            attr_writer :records

            def self.build(trace=nil)
              instance = new

              if not trace.nil?
                instance.trace = trace
              end

              instance
            end

            def receive(event_data)
              trace_copy = Trace.new

              trace.each do |entry|
                trace_copy.push(entry)
              end

              record = Record.new(event_data, trace_copy)
              records.push(record)

              record
            end

            def received?(event_data=nil)
              if not event_data.nil?
                records.any? do |record|
                  record.event_data == event_data
                end
              else
                records.any?
              end
            end

            def one_event?(event_class, *titles, **attributes)
              event_sink = event_sink(*titles)
              event_sink.one_event?(event_class, **attributes)
            end

            def one_event(event_class, *titles, **attributes)
              event_sink = event_sink(*titles)
              event_sink.one_event(event_class, **attributes)
            end

            def any_event?(event_class, *titles, **attributes)
              event_sink = event_sink(*titles)
              event_sink.any_event?(event_class, **attributes)
            end
            alias :event? :any_event?

            def events(event_class, *titles, **attributes)
              event_sink = event_sink(*titles)
              event_sink.events(event_class, **attributes)
            end

            def event_sink(*titles)
              event_sink = Telemetry::Substitute::Sink.new

              records.each do |record|
                if record.match?(titles)
                  event_data = record.event_data

                  event_sink.receive(event_data)
                end
              end

              event_sink
            end

            Record = Struct.new(:event_data, :trace) do
              def match?(titles)
                if titles.any?
                  trace.match?(*titles)
                else
                  true
                end
              end
            end
          end
        end
      end
    end
  end
end
