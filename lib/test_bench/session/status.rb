module TestBench
  class Session
    Status = Struct.new(:test_sequence, :failure_sequence, :error_sequence, :skip_sequence)

    class Status
      def self.initial
        new(0, 0, 0, 0)
      end

      def result(previous_status=nil, pending_event=nil)
        previous_status ||= Status.initial

        compare_status = compare(previous_status)

        if not pending_event.nil?
          compare_status.update(pending_event)
        end

        if compare_status.error_sequence > 0
          Result.aborted
        elsif compare_status.failure_sequence > 0
          Result.failed
        elsif compare_status.skip_sequence > 0
          Result.incomplete
        elsif not compare_status.test_sequence > 0
          Result.none
        else
          Result.passed
        end
      end

      def update(event)
        case event
        when Events::TestFinished
          self.test_sequence += 1
        when Events::Failed
          self.failure_sequence += 1
        when Events::Aborted, Events::FileNotFound
          self.error_sequence += 1
        when Events::Skipped
          self.skip_sequence += 1
        end
      end

  				def compare(previous_status)
  					test_sequence_difference = test_sequence - previous_status.test_sequence

  					failure_sequence_difference = failure_sequence - previous_status.failure_sequence

  					error_sequence_difference = error_sequence - previous_status.error_sequence

  					skip_sequence_difference = skip_sequence - previous_status.skip_sequence

  					Status.new(test_sequence_difference, failure_sequence_difference, error_sequence_difference, skip_sequence_difference)
  				end
    end
  end
end
