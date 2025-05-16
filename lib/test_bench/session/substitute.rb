module TestBench
  class Session
    module Substitute
      def self.build
        Session.build
      end

      class Session < Session
        def sink
          @sink ||= Sink.build(trace)
        end

        attr_accessor :record_file_not_found

        def record_file_not_found!
          self.record_file_not_found = true
        end

        def self.build
          instance = new

          sink = instance.sink

          telemetry = instance.telemetry
          telemetry.register(sink)

          instance
        end

        def executed?(...)
          isolate.executed?(...)
        end

        def file_not_found?(_file_path)
          record_file_not_found ? true : false
        end

        def one_passed_test_finished_event?(*, **)
          result = Result.passed

          one_test_finished_event?(*, **, result:)
        end
        alias :one_test_passed? :one_passed_test_finished_event?

        def one_passed_test_finished_event(*, **)
          result = Result.passed

          one_test_finished_event(*, **, result:)
        end
        alias :one_passed_test :one_passed_test_finished_event

        def any_passed_test_finished_event?(*, **)
          result = Result.passed

          any_test_finished_event?(*, **, result:)
        end
        alias :any_test_passed? :any_passed_test_finished_event?
        alias :test_passed? :any_test_passed?

        def passed_test_finished_events(*, **)
          result = Result.passed

          test_finished_events(*, **, result:)
        end
        alias :passed_tests :passed_test_finished_events

        def one_failed_test_finished_event?(*, **)
          result = Result.failed

          one_test_finished_event?(*, **, result:)
        end
        alias :one_test_failed? :one_failed_test_finished_event?

        def one_failed_test_finished_event(*, **)
          result = Result.failed

          one_test_finished_event(*, **, result:)
        end
        alias :one_failed_test :one_failed_test_finished_event

        def any_failed_test_finished_event?(*, **)
          result = Result.failed

          any_test_finished_event?(*, **, result:)
        end
        alias :any_test_failed? :any_failed_test_finished_event?
        alias :test_failed? :any_test_failed?

        def failed_test_finished_events(*, **)
          result = Result.failed

          test_finished_events(*, **, result:)
        end
        alias :failed_tests :failed_test_finished_events

        [
          Events::Failed,
          Events::Aborted,
          Events::Skipped,
          Events::Commented,
          Events::Detailed,
          Events::TestStarted,
          Events::TestFinished,
          Events::ContextStarted,
          Events::ContextFinished,
          Events::FileQueued,
          Events::FileExecuted,
          Events::FileNotFound
        ].each do |event_class|

          event_name = event_class.event_name

          module_eval(<<~RUBY, __FILE__, __LINE__)
          def one_#{event_name}_event?(...)
            one_event?(#{event_class}, ...)
          end

          def one_#{event_name}_event(...)
            one_event(#{event_class}, ...)
          end

          def any_#{event_name}_event?(...)
            any_event?(#{event_class}, ...)
          end
          alias :#{event_name}_event? :any_#{event_name}_event?

          def #{event_name}_events(...)
            events(#{event_class}, ...)
          end
          RUBY
        end

        def one_event?(...)
          sink.one_event?(...)
        end

        def any_event?(...)
          sink.any_event?(...)
        end
        alias :event? :any_event?

        def one_event(...)
          sink.one_event(...)
        end

        def events(...)
          sink.events(...)
        end
      end
    end
  end
end
