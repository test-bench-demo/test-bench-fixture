module TestBench
  module Test
    module Automated
      class Output
        include Telemetry::Sink::Handler
        include ImportConstants

        import_constants Session::Events

        Result = Session::Result

        def writer
          @writer ||= Writer::Substitute.build
        end
        attr_writer :writer

        def detail_policy
          @detail_policy ||= DetailPolicy.on
        end
        attr_writer :detail_policy

        def output_level
          @output_level ||= Level.all
        end
        attr_writer :output_level

        def branches
          @branches ||= []
        end
        attr_writer :branches

        def status
          @status ||= Session::Status.initial
        end
        attr_writer :status

        def self.build(styling: nil, device: nil)
          instance = new

          instance.detail_policy = Defaults.detail_policy
          instance.output_level = Defaults.output_level

          Writer.configure(instance, styling:, device:)

          instance
        end

        def self.register_telemetry_sink(session=nil, styling: nil, device: nil)
          session ||= Session.instance

          output = build(styling:, device:)

          session.register_telemetry_sink(output)

          output
        end

        handle Failed do |failed|
          pend(failed)
        end

        handle Aborted do |aborted|
          pend(aborted)
        end

        handle Skipped do |skipped|
          pend(skipped)
        end

        handle Commented do |commented|
          pend(commented)
        end

        handle Detailed do |detailed|
          pend(detailed)
        end

        handle TestStarted do |test_started|
          branch(test_started)
        end

        handle TestFinished do |test_finished|
          merge(test_finished)
        end

        handle ContextStarted do |context_started|
          branch(context_started)
        end

        handle ContextFinished do |context_finished|
          merge(context_finished)
        end

        handle FileQueued do |file_queued|
          branch(file_queued)
        end

        handle FileExecuted do |file_executed|
          merge(file_executed)
        end

        handle FileNotFound do |file_not_found|
          pend(file_not_found)
        end

        def merge(event)
          pend(event)

          merge_branch = branches.pop

          if root?
            if not Level.output?(output_level, merge_branch.status.result)
              return
            end

            merge_branch.each do |event, status|
              resolve(event, status)
            end
          else
            current_branch.merge(merge_branch)
          end
        end

        def branch(event)
          branch = Branch.new

          branches << branch

          pend(event)

          branch
        end

        def pend(event)
          status.update(event)

          if root?
            resolve(event, status)
          else
            current_branch.pend(event)
          end
        end

        def current_branch
          branches.last
        end

        def root?
          current_branch.nil?
        end

        def resolve(event, status)
          case event
          in Failed => failed
            resolve_failed(failed)
          in Aborted => aborted
            resolve_aborted(aborted)
          in Skipped => skipped
            resolve_skipped(skipped)
          in Commented => commented
            resolve_commented(commented)
          in Detailed => detailed
            resolve_detailed(detailed, status)
          in TestStarted => test_started
            resolve_test_started(test_started, status)
          in TestFinished => test_finished
            resolve_test_finished(test_finished)
          in ContextStarted => context_started
            resolve_context_started(context_started, status)
          in ContextFinished => context_finished
            resolve_context_finished(context_finished, status)
          in FileQueued => file_queued
            resolve_file_queued(file_queued, status)
          in FileExecuted => file_executed
            resolve_file_executed(file_executed)
          in FileNotFound => file_not_found
            resolve_file_not_found(file_not_found)
          else
          end
        end

        def resolve_failed(failed)
          message = failed.message

          writer.
            indent.
            style(:red).
            puts(message)
        end

        def resolve_aborted(aborted)
          message = aborted.message

          writer.
            indent.
            style(:bold, :red).
            print("Aborted: ").
            style(:reset_intensity).
            puts(message)
        end

        def resolve_skipped(skipped)
          message = skipped.message

          writer.
            indent.
            style(:yellow)

          if not message.nil?
            writer.print(message)

            if not writer.styling?
              writer.print(" (skipped)")
            end
          else
            writer.print("Skipped")
          end

          writer.puts
        end

        def resolve_commented(commented)
          text = commented.text

          disposition = commented.disposition
          style = CommentStyle.fetch(disposition)

          case style
          when CommentStyle.detect
            if text.end_with?("\n")
              style = CommentStyle.block
            else
              style = CommentStyle.normal
            end

          when CommentStyle.raw
            writer.
              print(text).
              print("\n")

            return
          end

          if text.empty?
            writer.
              indent.
              style(:faint, :italic)

            if style == CommentStyle.heading
              writer.puts('(no heading)')

              if not writer.styling?
                writer.
                  indent.
                  puts("- - -")
              end
            else
              writer.puts('(empty)')
            end

            return
          end

          case style
          when CommentStyle.normal
            writer.
              indent.
              puts(text)

          when CommentStyle.heading
            writer.
              indent.
              style(:bold).
              puts(text)

            if not writer.styling?
              writer.
                indent.
                puts("- - -")
            end

          when CommentStyle.block
            text.each_line do |line|
              writer.
                indent.
                style(:reverse_video)

              if writer.styling?
                writer.print(' ')
              else
                writer.print('>')
              end

              writer.
                style(:reset_reverse_video).
                print(' ').
                puts(line)
            end

          when CommentStyle.file
            lines = text.each_line

            final_line_number_width = lines.count.to_s.length
            marker_width = final_line_number_width + 2

            lines.with_index(1) do |line, line_number|
              line_marker = "#{line_number}.".ljust(marker_width)

              writer.
                indent.
                style(:faint).
                print(line_marker).
                style(:reset_intensity).
                puts(line)
            end
          end
        end

        def resolve_detailed(detailed, status)
          result = status.result

          print_detail = DetailPolicy.detail?(detail_policy, result)

          if print_detail
            resolve_commented(detailed)
          end
        end

        def resolve_test_started(test_started, status)
          title = test_started.title

          if title.nil?
            return
          end

          writer.indent

          result = status.result

          case result
          when Result.passed
            writer.style(:green)
          when Result.failed, Result.aborted, Result.incomplete, Result.none
            writer.style(:bold, :red)
          end

          writer.print(title)

          if not writer.styling?
            case result
            when Result.aborted
              writer.print(" (aborted)")
            when Result.failed
              writer.print(" (failed)")
            when Result.incomplete, Result.none
              writer.print(" (inconclusive)")
            end
          end

          writer.puts

          writer.increase_indentation
        end

        def resolve_test_finished(test_finished)
          title = test_finished.title

          if not title.nil?
            writer.decrease_indentation
          end
        end

        def resolve_context_started(context_started, status)
          title = context_started.title

          if title.nil?
            return
          end

          writer.indent

          result = status.result

          case result
          when Result.aborted
            writer.style(:red)
          when Result.passed, Result.failed, Result.incomplete
            writer.style(:green)
          end

          writer.print(title)

          if not writer.styling?
            if result == Result.aborted
              writer.print(" (aborted)")
            end
          end

          writer.puts

          writer.increase_indentation
        end

        def resolve_context_finished(context_finished, status)
          title = context_finished.title

          if title.nil?
            return
          end

          writer.decrease_indentation

          if not writer.indentation_depth.zero?
            return
          end

          error_count = status.error_sequence
          failure_count = status.failure_sequence
          skip_count = status.skip_sequence

          if error_count > 0 || failure_count > 0 || skip_count > 0
            writer.puts
          end

          if not error_count.zero?
            writer.
              style(:red).
              print("Errors: ").
              style(:bold).
              puts("#{status.error_sequence}")
          end

          if not failure_count.zero?
            writer.
              style(:red).
              print("Failures: ").
              style(:bold).
              puts("#{status.failure_sequence}")
          end

          if not skip_count.zero?
            writer.
              style(:yellow).
              print("Skipped: ").
              style(:bold).
              puts("#{status.skip_sequence}")
          end
        end

        def resolve_file_queued(file_queued, status)
          writer.indent

          if status.result == Session::Result.aborted
            writer.style(:bold, :red)
          end

          file = file_queued.file
          writer.print("Running #{file}")

          if !writer.styling? && status.result == Session::Result.aborted
            writer.print(" (aborted)")
          end

          writer.puts
        end

        def resolve_file_executed(file_executed)
          indented = writer.indentation_depth > 0

          result = file_executed.result

          if indented
            file = file_executed.file

            writer.
              indent.
              style(:italic).
              print("Ran #{file}")

            if result == Result.none
              writer.
                print(' ').
                style(:faint).
                print("(no tests)")
            end

            writer.puts
          else
            if result == Result.none
              writer.
                style(:faint, :italic).
                puts("(no tests)")
            end

            writer.puts
          end
        end

        def resolve_file_not_found(file_not_found)
          file = file_not_found.file

          writer.
            style(:red).
            print("File not found: ").
            style(:bold).
            puts(file).
            puts
        end

        class Branch
          def status
            @status ||= Session::Status.initial
          end
          attr_writer :status

          def entries
            @entries ||= []
          end
          attr_writer :entries

          def pend(event)
            status.update(event)

            entries << event
          end

          def merge(branch)
            branch_status = branch.status

            status.test_sequence += branch_status.test_sequence
            status.failure_sequence += branch_status.failure_sequence
            status.error_sequence += branch_status.error_sequence
            status.skip_sequence += branch_status.skip_sequence

            entries << branch
          end

          def each(&block)
            entries.each do |entry|
              case entry
              in Telemetry::Event => event
                block.(event, status)
              in Branch => branch
                branch.each(&block)
              end
            end
          end
        end

        module Defaults
          def self.detail_policy
            env_var_value = ENV.fetch('TEST_OUTPUT_DETAIL', 'failure')

            detail_policy = env_var_value.to_sym

            DetailPolicy.assure_policy(detail_policy)

            detail_policy
          end

          def self.output_level
            env_var_value = ENV.fetch('TEST_OUTPUT_LEVEL', 'all')

            output_level = env_var_value.gsub('-', '_').to_sym

            Level.assure_output_level(output_level)

            output_level
          end
        end
      end
    end
  end
end
