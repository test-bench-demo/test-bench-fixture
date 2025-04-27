module TestBench
  module Test
    module Automated
      class Session
        class Isolate
          def subprocess_sequence
            @subprocess_sequence ||= 0
          end
          attr_writer :subprocess_sequence

          def apex_directory
            @apex_directory ||= ::Dir.pwd
          end
          attr_writer :apex_directory

          attr_accessor :subprocess_id

          attr_accessor :telemetry_reader
          attr_accessor :file_path_writer

          def self.build(apex_directory: nil)
            instance = new
            instance.apex_directory = apex_directory
            instance
          end

          def self.configure(receiver, apex_directory: nil, attr_name: nil)
            attr_name ||= :isolate

            instance = build(apex_directory:)
            receiver.public_send(:"#{attr_name}=", instance)
          end

          def call(file_path, &probe)
            case status
            when Status.stopping
              stop
              start
            when Status.stopped
              start
            end

            file_path_writer.puts(file_path)

            loop do
              event_data_text = telemetry_reader.gets

              event_data = Telemetry::EventData.load(event_data_text)

              if Isolated === event_data
                executed_file_path, result = event_data.data

                if executed_file_path == file_path
                  if result == Result.aborted
                    stop!
                  end

                  break
                else
                  next
                end
              end

              probe.(event_data)
            end
          end

          def start
            file_path_reader, file_path_writer = IO.pipe
            telemetry_reader, telemetry_writer = IO.pipe

            subprocess_id = fork do
              file_path_writer.close
              telemetry_reader.close

              ::Dir.chdir(apex_directory)

              session = Session.build

              telemetry_sink = Telemetry::Sink::File.new(telemetry_writer)
              session.register_telemetry_sink(telemetry_sink)

              Session.establish(session)

              while file_path = file_path_reader.gets(chomp: true)
                pending_event = Isolated.build(file_path)

                absolute_file_path = ::File.expand_path(file_path)

                session.evaluate(pending_event) do
                  load(absolute_file_path)
                end
              end

            ensure
              # Ensure any exception raised by the subprocess is likely to be printed after the session's test output
              one_millisecond = 0.001
              sleep(one_millisecond)
            end

            telemetry_writer.close
            file_path_reader.close

            self.subprocess_id = subprocess_id
            self.subprocess_sequence += 1

            self.telemetry_reader = telemetry_reader
            self.file_path_writer = file_path_writer

            subprocess_id
          end

          def stop
            stop!

            subprocess_status = ::Process::Status.wait(subprocess_id)

            self.subprocess_id = nil

            subprocess_status.exitstatus
          end

          def stop!
            telemetry_reader&.close
            file_path_writer&.close
          end

          def status
            if subprocess_id.nil?
              Status.stopped
            elsif telemetry_reader.closed? && file_path_writer.closed?
              Status.stopping
            else
              Status.active
            end
          end

          Isolated = Telemetry::Event.define(:file, :result)

          module Status
            def self.active
              :active
            end

            def self.stopping
              :stopping
            end

            def self.stopped
              :stopped
            end
          end
        end
      end
    end
  end
end
