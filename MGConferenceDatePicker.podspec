Pod::Spec.new do |s|
  s.name     = 'MGConferenceDatePicker'
  s.version  = '1.0.0'
  s.platform = :ios, '7.0'
  s.summary  = 'MGConferenceDatePicker is an object wich extend a UIView furnishing a very nice type of data picker.'
  s.homepage = 'https://github.com/matteogobbi/MGConferenceDatePicker'
  s.author   = { 'Matteo Gobbi' => 'job@matteogobbi.it' }
  s.source   = { :git => 'https://github.com/matteogobbi/MGConferenceDatePicker.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.source_files = 'MGConferenceDatePicker/MGConferenceDatePicker/*.{h,m,xcassets}'
  s.requires_arc = true
end