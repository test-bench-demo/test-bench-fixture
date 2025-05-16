module TestBench
  class Output
    module CommentStyle
      Error = Class.new(RuntimeError)

      def self.fetch(comment_disposition)
        comment_style = get(comment_disposition)

        comment_style ||= normal

        comment_style
      end

      def self.get(comment_disposition)
        comment_style, _ = comment_styles.rassoc(comment_disposition)
        comment_style
      end

      def self.get_disposition(comment_style)
        comment_styles.fetch(comment_style) do
          raise Error, "Incorrect comment style: #{comment_style.inspect}"
        end
      end

      def self.comment_styles
        {
          :detect => 'detect',
          :normal => 'normal',
          :heading => 'heading',
          :block => 'block',
          :file => 'file',
          :raw => 'raw'
        }
      end

      def self.detect
        :detect
      end

      def self.normal
        :normal
      end

      def self.heading
        :heading
      end

      def self.block
        :block
      end

      def self.file
        :file
      end

      def self.raw
        :raw
      end
    end
  end
end
