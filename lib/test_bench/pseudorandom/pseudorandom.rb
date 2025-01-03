module TestBench
  module Pseudorandom
    extend self

    def reset
      Generator.instance.reset
    end

    def string
      Generator.instance.string
    end

    def boolean
      Generator.instance.boolean
    end

    def integer
      Generator.instance.integer
    end

    def decimal
      Generator.instance.decimal
    end
  end
end
