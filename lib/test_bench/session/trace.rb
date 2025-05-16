module TestBench
  class Session
    class Trace
      include Enumerable

      def entries
        @entries ||= []
      end
      attr_writer :entries

      def push(entry)
        entries.push(entry)
      end

      def pop
        entries.pop
      end

      def match?(*context_titles, compare_text)
        if compare_text != entries.last
          return false
        end

        context_title_iterator = entries[0...-1].to_enum

        context_titles.all? do |context_title|
          title = context_title_iterator.next until title == context_title

          true

        rescue StopIteration

          false
        end
      end

      def each(...)
        entries.each(...)
      end

      def join(delimiter=nil)
        delimiter ||= self.class.join_delimiter

        entries.join(delimiter)
      end

      def self.join_delimiter
        ' :: '
      end
    end
  end
end
