module TestBench
  class Output
    module Level
      Error = Class.new(RuntimeError)

      def self.abort
        :abort
      end

      def self.failure
        :failure
      end

      def self.not_passing
        :not_passing
      end

      def self.all
        :all
      end

      def self.output?(output_level, result=nil)
        result ||= Session::Result.none

        case output_level
        when abort
          result == Session::Result.aborted

        when failure
          [
            Session::Result.aborted,
            Session::Result.failed
          ].include?(result)

        when not_passing
          result != Session::Result.passed

        when all
          true

        else
          raise Error, "Incorrect output level: #{output_level.inspect}"
        end
      end

      def self.assure_output_level(output_level)
        output?(output_level)
      end
    end
  end
end
