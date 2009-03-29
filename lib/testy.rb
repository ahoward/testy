require 'rubygems'
require 'orderedhash'
require 'yaml'

module Testy
  def Testy.version() '0.4.2' end

  class Test
    class BadResult < StandardError
    end

    class OrderedHash < ::OrderedHash
      def with_string_keys
        oh = self.class.new
        each_pair{|key, val| oh[key.to_s] = val}
        oh
      end
    end

    class Result
      attr_accessor :expect
      attr_accessor :actual

      def initialize
        @expect = OrderedHash.new
        @actual = OrderedHash.new
      end

      def check(name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        value = args.size==0 ? (options[:expect]||options['expect']) : args.shift
        expect[name.to_s] = value
        value = args.size==0 ? (options[:actual]||options['actual']) : args.shift
        actual[name.to_s] = value
      end

      def ok?
        expect === actual
      end
    end

    attr_accessor :name
    attr_accessor :tests
    attr_accessor :block

    def initialize(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      @name = args.first || options[:name] || options['name']
      @tests = OrderedHash.new
      @block = block
    end

    def test(name, &block)
      @tests[name.to_s] = block
    end

    def run(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      port = options[:port]||options['port']||STDOUT
      selectors = options[:selectors]||options['selectors']||[]
      instance_eval(&@block) if @block
      report = OrderedHash.new
      failures = 0
      tests.each do |name, block|
        next unless selectors.any?{|selector| selector===name} unless selectors.empty?
        result = Result.new
        report[name] =
          begin
            block.call(result)
            raise BadResult, name unless result.ok?
            {'success' => result.actual.with_string_keys}
          rescue Object => e
            failures += 1
            failure = OrderedHash.new
            unless e.is_a?(BadResult)
              error = OrderedHash.new
              error['class'] = e.class.name
              error['message'] = e.message.to_s
              error['backtrace'] = e.backtrace||[]
              failure['error'] = error
            end
            failure['expect'] = result.expect.with_string_keys
            failure['actual'] = result.actual.with_string_keys
            {'failure' => failure}
          end
      end
      port << {name => report}.to_yaml
      failures
    end
  end
    
  def Testy.testing(*args, &block)
    selectors = ARGV.map{|arg| eval(arg =~ %r|^/.*| ? arg : "/^#{ arg }/")}
    failures = Test.new(*args, &block).run(:port => STDOUT, :selectors => selectors)
    exit(failures)
  end
end
