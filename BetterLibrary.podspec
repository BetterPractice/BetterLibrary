Pod::Spec.new do |s|
  s.name = "BetterLibrary"
  s.summary = "A Better Library to make Swift programming cleaner and more efficient."
  s.homepage = "https://github.com/BetterPractice/BetterLibrary"
  s.authors = { "hollyschilling" => "holly.a.schilling@outlook.com" }
  s.version = '2.0.0'
  s.license = { :type => 'Apache', :file => 'LICENSE.txt' }
  s.source = { :git => "https://github.com/BetterPractice/BetterLibrary.git", :tag => s.version }

  s.ios.deployment_target = "9.0"
  s.source_files = 'Sources/BetterLibrary/**/*.swift'
end

