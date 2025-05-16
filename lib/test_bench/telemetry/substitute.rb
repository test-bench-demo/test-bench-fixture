module TestBench
  class Telemetry
    module Substitute
      def self.build
        Telemetry.build
      end

      class Telemetry < Telemetry
        attr_accessor :process_id
        attr_accessor :current_time

        def sink
          @sink ||= Substitute::Sink.new
        end
        attr_writer :sink

        def self.build
          instance = new
          instance.register(instance.sink)
          instance
        end

        def one_event?(...) = sink.one_event?(...)
        def one_event(...) = sink.one_event(...)
        def any_event?(...) = sink.any_event?(...)
        alias :event? :any_event?
        def events(...) = sink.events(...)

        def recorded?(event_or_event_data)
          case event_or_event_data
          in Event => event
            event_data = Event::Export.(event)
          in EventData => event_data
          end

          sink.received?(event_data)
        end
      end
    end
  end
end
