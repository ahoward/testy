#! /usr/bin/env gem build

require 'rubygems'

Gem::Specification::new do |spec|
  $VERBOSE = nil

  shiteless = lambda do |list|
    list.delete_if do |file|
      file =~ %r/\.git/ or
      file =~ %r/\.svn/ or
      file =~ %r/\.tmp/
    end
  end

  spec.name = $lib
  spec.version = $version
  spec.platform = Gem::Platform::RUBY
  spec.summary = $lib

  spec.files = shiteless[Dir::glob("**/**")]
  spec.executables = shiteless[Dir::glob("bin/*")].map{|exe| File::basename(exe)}
  
  spec.require_path = "lib" 

  spec.has_rdoc = true

  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://github.com/ahoward/testy/tree/master"
end


BEGIN{ 
  Dir.chdir(File.dirname(__FILE__))
  $lib = 'testy'
  Kernel.load "./lib/#{ $lib }.rb"
  $version = Testy.version
}
