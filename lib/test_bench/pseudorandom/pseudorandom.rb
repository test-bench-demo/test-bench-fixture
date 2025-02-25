module TestBench
  module Pseudorandom
    extend self

    def reset(namespace=nil)
      Generator.instance.reset(namespace)
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
