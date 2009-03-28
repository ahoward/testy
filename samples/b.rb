# testy will handle unexpected results and exceptions thrown in your code in
# exactly the same way - by reporting on them in a beautiful fashion and
# continuing to run other tests.  notice, however, that an unexpected result
# or raised exception will cause a non-zero exitstatus (equalling the number
# of failed tests) for the suite as a whole.  also note that previously
# accumulate expect/actual pairs are still reported on in the error report.
#
  require 'testy'

  Testy.testing 'the exception handling of testy' do

    test 'raising an exception' do |result|
      list = []

      list << 42
      result.check :a, :expect => 42, :actual => list.first

      list.method_that_does_not_exist
    end

    test 'returning unexpected results' do |result|
      result.check 'a', 42, 42
      result.check :b, :expect => 'forty-two', :actual => 42.0
    end

  end
