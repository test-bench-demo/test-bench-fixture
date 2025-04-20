module TestBench
  module Test
    module Automated
      module Fixture
        module Build
          Error = ::Class.new(RuntimeError)

          def self.call(fixture_class, *, test_session: nil, **, &)
            assure_fixture(fixture_class)

            if fixture_class.respond_to?(:build)
              constructor = :build
            else
              constructor = :new
            end

            fixture = fixture_class.public_send(constructor, *, **, &)

            Session.configure(
              fixture,
              session: test_session,
              attr_name: :test_session
            )

            fixture
          end

          def self.assure_fixture(fixture_class)
            is_class = fixture_class.instance_of?(::Class)
            if not is_class
              raise Error, "Not a class (Class: #{fixture_class})"
            end

            is_fixture_class = fixture_class.included_modules.include?(Fixture)
            if not is_fixture_class
              raise Error, "Not a fixture class (Class: #{fixture_class})"
            end
          end
        end
      end
    end
  end
end
