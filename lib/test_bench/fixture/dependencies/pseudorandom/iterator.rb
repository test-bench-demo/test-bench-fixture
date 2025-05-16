module TestBench
  module Fixture
    module Dependencies
      module Pseudorandom
        class Iterator
          attr_accessor :seed

          def iterations
            @iterations ||= 0
          end
          attr_writer :iterations

          attr_reader :random

          def initialize(random)
            @random = random
          end

          def self.build(seed)
            random = self.random(seed)

            instance = new(random)
            instance.seed = seed
            instance
          end

          def self.random(seed)
            random_seed = seed.to_i(36)

            ::Random.new(random_seed)
          end

          def next
            self.iterations += 1

            random.bytes(8)
          end

          def seed?(seed)
            control_random = ::Random.new(random.seed)
            compare_random = Iterator.random(seed)

            control_value = control_random.rand
            compare_value = compare_random.rand

            control_value == compare_value
          end

          def iterated?
            iterations > 0
          end
        end
      end
    end
  end
end
