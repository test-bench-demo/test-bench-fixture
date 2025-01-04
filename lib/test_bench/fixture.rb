require 'test_bench/digest/hash'
require 'test_bench/import_constants'
require 'test_bench/pseudorandom'
require 'test_bench/test/telemetry'
require 'test_bench/test/output/writer'
require 'test_bench/test/session'
require 'test_bench/test/fixture'

[
  "digest/hash",
  "import_constants",
  "pseudorandom",
  "test/telemetry",
  "test/output/writer",
  "test/session",
  "test/fixture"
].each do |original_gem_feature|
  require original_gem_feature
rescue LoadError
  $LOADED_FEATURES.push("#{original_gem_feature}.rb")
end

TestBench::ImportConstants.(TestBench)

module TestBench
  Fixture = Test::Fixture
end
