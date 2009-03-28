# simple use of testy involves simply writing code, and recording the result
# you expect against the actual result
#
# notice that the output is very pretty and that the exitstatus is 0 when all
# tests pass
#
  require 'testy'

  Testy.testing 'the kick-ass-ed-ness of testy' do

    test 'the ultimate answer to life' do |result|
      list = []

      list << 42
      result.check :a, :expect => 42, :actual => list.first

      list << 42.0
      result.check :b, 42.0, list.last
    end

  end
