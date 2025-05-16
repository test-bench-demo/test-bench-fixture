module TestBench
  class Output
    module DetailPolicy
      Error = Class.new(RuntimeError)

      def self.failure
        :failure
      end

      def self.on
        :on
      end

      def self.off
        :off
      end

      def self.detail?(detail_policy, result=nil)
        result ||= Session::Result.none

        case detail_policy
        when failure
          [
            Session::Result.failed,
            Session::Result.aborted
          ].include?(result)

        when on
          true

        when off
          false

        else
          raise Error, "Incorrect detail policy: #{detail_policy.inspect}"
        end
      end

      def self.assure_policy(detail_policy)
        detail?(detail_policy)
      end
    end
  end
end
