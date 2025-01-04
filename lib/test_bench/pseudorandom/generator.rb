module TestBench
  module Pseudorandom
    class Generator
      def iterator
        @iterator ||= Iterator.build(seed)
      end
      attr_writer :iterator

      attr_accessor :seed
      alias :set_seed :seed=

      def initialize(seed)
        @seed = seed
      end

      def self.build(seed=nil)
        seed ||= Defaults.seed

        new(seed)
      end

      def self.instance
        @instance ||= build
      end

      def self.configure(receiver, attr_name: nil)
        attr_name ||= :random_generator

        instance = self.instance
        receiver.public_send(:"#{attr_name}=", instance)
      end

      def string
        self.integer.to_s(36)
      end

      def boolean
        self.integer % 2 == 1
      end

      def integer
        iterator.next.unpack1('Q>')
      end

      def decimal
        iterator.next.unpack1('D')
      end

      def reset(namespace=nil)
        self.iterator = Iterator.build(seed, namespace)
      end

      def reset?(namespace=nil)
        if iterator.iterated?
          false
        elsif namespace.nil?
          true
        else
          iterator.namespace?(namespace)
        end
      end

      def namespace?(namespace)
        iterator.namespace?(namespace)
      end
    end
  end
end
