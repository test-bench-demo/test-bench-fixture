module TestBench
  module Digest
    class Hash
      module IrrationalNumber
        PI = Rational(
          0xFFFF_FFFF_FFFF_FFFF,
          0x517C_C1B7_2722_0A95
        )

        def self.get
          PI
        end

        def self.numerator
          PI.numerator
        end

        def self.denominator
          PI.denominator
        end
      end
    end
  end
end
