module TestBench
  module Pseudorandom
    class Iterator
      attr_accessor :seed
      attr_accessor :namespace

      def iterations
        @iterations ||= 0
      end
      attr_writer :iterations

      attr_reader :random

      def initialize(random)
        @random = random
      end

      def self.build(seed, namespace=nil)
        random = self.random(seed, namespace)

        instance = new(random)
        instance.seed = seed
        instance.namespace = namespace
        instance
      end

      def self.random(seed, namespace)
        random_seed = seed.to_i(36)

        if not namespace.nil?
          namespace_hash = namespace_hash(namespace)
          random_seed ^= namespace_hash
        end

        ::Random.new(random_seed)
      end

      def self.namespace_hash(namespace)
        namespace_digest = Digest::Hash.digest(namespace)

        namespace_digest.unpack1('Q>')
      end

      def next
        self.iterations += 1

        random.bytes(8)
      end

      def namespace?(namespace)
        source?(self.seed, namespace)
      end

      def seed?(seed)
        source?(seed, self.namespace)
      end

      def iterated?
        iterations > 0
      end

      def source?(seed, namespace=nil)
        control_random = ::Random.new(random.seed)
        compare_random = Iterator.random(seed, namespace)

        control_value = control_random.rand
        compare_value = compare_random.rand

        control_value == compare_value
      end
    end
  end
end
