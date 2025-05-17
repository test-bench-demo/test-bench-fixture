require 'json'

require 'test_bench/fixture/dependencies'
TestBench::Fixture::Dependencies::ImportConstants.(TestBench::Fixture::Dependencies)

require 'test_bench/fixture/load'
require 'test_bench/fixture/fixture'

module Test
  module Automated
    TestBench::Fixture::Dependencies::ImportConstants.(TestBench, self)
  end
end

[
  'import_constants',
  'pseudorandom',
  'test/automated/telemetry',
  'test/automated/session',
  'test/automated/output',
  'test/automated/fixture'
].each do |feature|
  $LOADED_FEATURES.push(feature)
end
