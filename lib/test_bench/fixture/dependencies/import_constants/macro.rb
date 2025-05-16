module TestBench
  module Fixture
    module Dependencies
      module ImportConstants
        module Macro
          def import_constants_macro(source_namespace, as: nil)
            ImportConstants.(source_namespace, self, as:)
          end
          alias :import_constants :import_constants_macro
        end
      end
    end
  end
end
