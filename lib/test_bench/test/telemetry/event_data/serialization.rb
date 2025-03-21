module TestBench
  module Test
    class Telemetry
      class EventData
        module Serialization
          def self.dump(event_data)
            data = event_data.data.map do |value|
              case value
              in Time => time
                timestamp(time)
              else
                value
              end
            end

            type = event_data.type
            process_id = event_data.process_id

            time = event_data.time
            timestamp = timestamp(time)

            json_text = JSON.generate([type, process_id, timestamp, data])
            json_text << "\n"
            json_text
          end

          def self.load(text)
            type, process_id, timestamp, data = JSON.parse(text)

            type = type.to_sym

            time = time(timestamp)

            event_data = EventData.new
            event_data.type = type
            event_data.process_id = process_id
            event_data.time = time
            event_data.data = data

            event_data
          end

          def self.timestamp(time)
            time.strftime('%Y-%m-%dT%H:%M:%S.%NZ')
          end

          def self.time(timestamp)
            match_data = time_pattern.match(timestamp)

            year = match_data['year'].to_i
            month = match_data['month'].to_i
            day = match_data['day'].to_i
            hour = match_data['hour'].to_i
            minute = match_data['minute'].to_i
            second = match_data['second'].to_i

            nanosecond = match_data['nanosecond'].to_i
            usec = Rational(nanosecond, 1_000)

            Time.utc(year, month, day, hour, minute, second, usec)
          end

          def self.time_pattern
            @time_pattern ||=
              begin
                year = %r{(?<year>[[:digit:]]{4})}
                month = %r{(?<month>[[:digit:]]{2})}
                day = %r{(?<day>[[:digit:]]{2})}
                hour = %r{(?<hour>[[:digit:]]{2})}
                minute = %r{(?<minute>[[:digit:]]{2})}
                second = %r{(?<second>[[:digit:]]{2})}
                nanosecond = %r{(?<nanosecond>[[:digit:]]{9})}

                %r{\A#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}\.#{nanosecond}Z\z}
              end
          end
        end
      end
    end
  end
end
