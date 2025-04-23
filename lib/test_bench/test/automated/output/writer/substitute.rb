module TestBench
  module Test
    module Automated
      class Output
        class Writer
          module Substitute
            def self.build
              Writer.build
            end

            class Writer < Writer
              attr_accessor :restored

              def self.build
                instance = new
                instance.enable_buffering
                instance
              end

              def set_styling
                self.styling = true
              end

              def written?(text=nil)
                if not text.nil?
                  text == self.written_text
                else
                  !written_text.empty?
                end
              end

              def written_text
                buffered_text
              end

              def restored?(text=nil)
                if detached? || buffering?
                  false
                elsif text.nil?
                  true
                else
                  device.written?(text)
                end
              end
            end
          end
        end
      end
    end
  end
end
