# of course testy includes smartly inherited contexts and context sensitive
# setup and teardown methods which stack as well.
#
  require 'testy'

  Testy.testing 'your bitchin lib' do
    context 'A' do
      setup{ @list = [40] }

      test 'foo' do
        @list << 2
        @list.first + @list.last
      end

      test 'bar' do |t|
        t.check :list, @list, [40]
      end

      context 'B' do
        setup{ @list << 2 }
        test(:bar){ @list.join.delete('0') }
      end
    end
  end


# the context name is applied to the test name, so you can selectively run
# groups of tests from the command line
#
# cfp:~/src/git/testy > ruby -I lib samples/d.rb 'A - B'
# --- 
# your bitchin lib: 
#   A - B - bar: 
#       success: "42"
