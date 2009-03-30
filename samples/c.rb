# in some cases you may not even want to make test assertions and simply
# provide example code which should run without error, with testy it's not
# only easy to do this but the commanline supports --list to see which samples
# can be run and running a single or multiple tests based on name or pattern.
# notice that, when no assertions are made using 'result.check' the output of
# the test becomes the expected *and* actual and is therefore shown in the
# output as yaml.  of course, if your samples have errors they are reported in
# the normal fashion and the tests will fail.
#
#
  require 'testy'

  Testy.testing 'some samplz for you' do
    test 'foo sample' do
      list = 1,2
      list.last + list.first
    end

    test 'bar sample' do
      list = 1,2
      list.shift * list.pop
    end

    test 'foobar sample' do
      list = 1,2
      eval(list.reverse.join) * 2
    end
  end

# here are some examples of using the command line arguments on the above test
#
# cfp:~/src/git/testy > ruby samples/c.rb --list
# --- 
# - foo sample
# - bar sample
# - foobar sample
#
# cfp:~/src/git/testy > ruby samples/c.rb foobar
# --- 
# some samplz for you: 
#   foobar sample: 
#     success: 42
#
# cfp:~/src/git/testy > ruby samples/c.rb foo
# --- 
# some samplz for you: 
#   foo sample: 
#     success: 3
#   foobar sample: 
#     success: 42
#
# cfp:~/src/git/testy > ruby samples/c.rb bar
# --- 
# some samplz for you: 
#   bar sample: 
#     success: 2
