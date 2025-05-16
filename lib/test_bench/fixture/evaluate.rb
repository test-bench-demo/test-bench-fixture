module TestBench
  module Fixture
    class Evaluate
      include Fixture

      attr_reader :block

      def initialize(block)
        @block = block
      end

      def self.build(test_session:, &block)
        instance = new(block)

        Session.configure(
          instance,
          session: test_session,
          attr_name: :test_session
        )

        instance
      end

      def self.call(test_session: nil, &block)
        instance = build(test_session:, &block)
        instance.()
        instance
      end

      def call
        instance_exec(&block)
      end
    end
  end
end
