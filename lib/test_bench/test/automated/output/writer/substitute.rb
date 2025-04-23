module TestBench
  module Test
    module Automated
      class Output
        class Writer
          module Substitute
            def self.build
              Writer.new
            end

            class Writer < Writer
              def set_styling
                self.styling = true
              end

              def written?(text=nil)
                device.written?(text)
              end

              def written_text
                device.written_text
              end
            end
          end
        end
      end
    end
  end
end
