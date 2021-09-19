require 'benchmark'
require_relative '../task-1'

Benchmark.bm do |x|
  GC.disable
  x.report('processing_time') { work('data_10000.txt') }
end