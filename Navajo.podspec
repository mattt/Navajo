Pod::Spec.new do |s|
  s.name     = 'Navajo'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'Password Validator & Strength Evaluator.'
  s.homepage = 'https://github.com/mattt/Navajo'
  s.social_media_url = 'https://twitter.com/mattt'
  s.screenshot = 'https://raw.github.com/mattt/Navajo/screenshots/example.gif'
  s.authors  = { 'Mattt' => 'mattt@me.com' }
  s.source   = { :git => 'https://github.com/mattt/Navajo.git', :tag => '1.0.0' }
  s.source_files = 'Navajo'
  s.requires_arc = true

  s.osx.frameworks = "CoreServices"

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
end
