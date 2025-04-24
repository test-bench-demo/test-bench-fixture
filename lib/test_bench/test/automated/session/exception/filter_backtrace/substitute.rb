module TestBench
  module Test
    module Automated
      class Session
        module Exception
          class FilterBacktrace
            module Substitute
              def self.build
                FilterBacktrace.new
              end

              class FilterBacktrace
                def exceptions
                  @exceptions ||= []
                end

                def call(exception)
                  exceptions << exception
                end

                def filtered?(exception)
                  exceptions.include?(exception)
                end
              end
            end
          end
        end
      end
    end
  end
end
