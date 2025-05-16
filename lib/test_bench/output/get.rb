module TestBench
  class Output
    module Get
      Error = Class.new(RuntimeError)

      def self.call(substitute_session, styling: nil)
        styling ||= false

        if not substitute_session.instance_of?(Session::Substitute::Session)
          raise Error, "Not a substitute session: #{substitute_session.inspect}"
        end

        output = Output.new

        if styling
          output.writer.set_styling
        end

        event_records = substitute_session.sink.records
        event_records.each do |record|
          event_data = record.event_data

          output.receive(event_data)
        end

        output.writer.written_text
      end
    end
  end
end
