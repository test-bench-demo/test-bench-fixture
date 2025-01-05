module TestBench
  module ImportConstants
    Error = Class.new(RuntimeError)

    def self.included(target_namespace)
      target_namespace.extend(Macro)
    end

    def self.call(source_namespace, target_namespace=nil, as: nil)
      target_namespace ||= Object
      alias_name = as

      if not alias_name.nil?
        if target_namespace.const_defined?(alias_name, false)
          raise Error, "#{target_namespace}::#{alias_name} is already defined"
        end

        alias_module = Module.new
        ImportConstants.(source_namespace, alias_module)

        target_namespace.const_set(alias_name, alias_module)

      else
        inherit = false
        constants = source_namespace.constants(inherit)

        constants.each do |constant_name|
          constant = source_namespace.const_get(constant_name)

          if target_namespace.const_defined?(constant_name)
            if warn?
              warn "#{source_namespace}::#{constant_name} is not imported into #{target_namespace}. It is already defined."
            end
            next
          end

          target_namespace.const_set(constant_name, constant)
        end
      end
    end

    def self.warn?
      ENV.fetch('IMPORT_CONSTANTS_WARNING', 'on') == 'on'
    end
  end
end
