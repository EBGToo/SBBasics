Pod::Spec.new do |s|
  s.name = 'SBBasics'
  s.version  = '0.1.0'
  s.summary  = 'Bags, Stacks, Queues, Lists, Heaps, Trees, Graphs'
  s.description = <<-DESC
Basics is a collection of largely standalone Swift abstractions for Bag type.
DESC
  s.homepage = 'https://github.com/EBGToo/SBBasics'

  s.license  = 'MIT'
  s.authors = { 'Ed Gamble' => 'ebg@opuslogica.com' }
  s.source  = { :git => 'https://github.com/EBGToo/SBBasics.git',
                :tag => s.version }
  s.source_files = 'Sources/*.swift'
  
  s.osx.deployment_target = '10.9'

  s.dependency "SBCommons", "~> 0.1"
end

