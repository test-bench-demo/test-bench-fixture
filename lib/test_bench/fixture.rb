require 'test_bench/import_constants'
require 'test_bench/pseudorandom'
require 'test_bench/test/automated/telemetry'
require 'test_bench/test/automated/session'
require 'test_bench/test/automated/output'
require 'test_bench/test/automated/fixture'

[
  "import_constants",
  "pseudorandom",
  "test/automated/telemetry",
  "test/automated/session",
  "test/automated/output",
  "test/automated/fixture"
].each do |original_gem_feature|
  require original_gem_feature
rescue LoadError
  $LOADED_FEATURES.push("#{original_gem_feature}.rb")
end

TestBench::ImportConstants.(TestBench)

module TestBench
  include Test::Automated
end
