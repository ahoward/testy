require 'rubygems'
require 'orderedhash'
require 'yaml'

module Testy
  def Testy.version() '0.5.0' end

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

      def empty?
        expect.empty? and actual.empty?
      end
    end

    attr_accessor :name
    attr_accessor :tests
    attr_accessor :block
    attr_accessor :contexts

    def initialize(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      @name = args.first || options[:name] || options['name']
      @tests = OrderedHash.new
      @contexts = OrderedHash.new
      @block = block
    end

    def test(name, &block)
      name = [contexts.values.map{|context| context.name}, name].flatten.compact.join(' - ')
      @tests[name] = [context, block]
    end

    def size
      @tests.size
    end

    class Context
      [:name, :block, :setup, :teardown].each{|name| attr_accessor name}
      def initialize(name = nil, setup = lambda{}, teardown = lambda{}, &block)
        @name, @setup, @teardown, @block = name, setup, teardown, block
      end
    end

    def context(name = nil, &block)
      if block
        @contexts[name] = Context.new(name, &block)
        block.call
      else
        @contexts.values.last
      end
    end

    def setup(&block)
      context.setup = block
    end

    def teardown(&block)
      context.teardown = block
    end

    def list
      instance_eval(&@block) if @block
      tests.map{|kv| kv.first.to_s}
    end

    def run(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      port = options[:port]||options['port']||STDOUT
      selectors = options[:selectors]||options['selectors']||[]

      context do
        instance_eval(&@block) if @block

        report = OrderedHash.new
        failures = 0

        tests.each do |name, context_and_block|
          next unless selectors.any?{|selector| selector===name} unless selectors.empty?

          result = Result.new

          dup.instance_eval do
            context, block = context_and_block

            contexts = []
            tests.each do |n, cb|
              c, b = cb
              break if context==c
              contexts << c
            end
            contexts << context

            report[name] =
              begin
                value =
                  begin
                    contexts.each{|context| instance_eval(&context.setup)}
                    (class << self;self;end).module_eval{ define_method(:call, &block) }
                    call(result)
                  ensure
                    contexts.reverse.each{|context| instance_eval(&context.teardown)}
                  end
                raise BadResult, name unless result.ok?
                value = result.actual.with_string_keys unless result.empty?
                begin; value.to_yaml; rescue; value=true; end
                {'success' => value}
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
        end
        port << {name => report}.to_yaml
        failures
      end
    end
  end
    
  def Testy.testing(*args, &block)
    list = ARGV.delete('--list')||ARGV.delete('-l')
    selectors = ARGV.map{|arg| eval(arg =~ %r|^/.*| ? arg : "/^#{ Regexp.escape(arg) }/")}
    test = Test.new(*args, &block)
    if list
      y test.list
    else
      failures = test.run(:selectors => selectors)
      size = test.size
      pct_failed = size==0 || failures==0 ? 0 : [ ((failures/size.to_f)*100).to_i, 1 ].max
      exit(pct_failed)
    end
  end
end
