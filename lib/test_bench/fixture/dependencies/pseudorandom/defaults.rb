module TestBench
  module Fixture
    module Dependencies
      module Pseudorandom
        module Defaults
          def self.seed
            ENV.fetch('SEED') do
              @seed ||= ::Random.new_seed.to_s(36)
            end
          end
        end
      end
    end
  end
end
