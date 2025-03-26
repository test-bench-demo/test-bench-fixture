module TestBench
  module Test
    class Session
      class Output
        module IndentStyle
          Error = Class.new(RuntimeError)

          extend self

          def self.get(text, heading=nil, indent_style=nil)
            assure_indent_style(indent_style, text, heading)
          end

          def self.assure_indent_style(indent_style, text=nil, heading=nil)
            text ||= ''

            case indent_style
            when *indent_styles
              indent_style
            when nil
              newline_terminated = text.match?(/\R\z/)

              if newline_terminated
                block
              else
                first_line
              end
            else
              raise Error, "Unknown indentation style #{indent_style.inspect}"
            end
          end

          def indent_styles
            [
              block,
              line_number,
              first_line,
              off
            ]
          end

          def block
            'block'
          end

          def line_number
            'line-number'
          end

          def first_line
            'first-line'
          end

          def off
            'off'
          end
        end
      end
    end
  end
end
