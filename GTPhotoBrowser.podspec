Pod::Spec.new do |s|
  s.name             = 'GTPhotoBrowser'
  s.version          = '1.0.0'
  s.summary          = 'A simple way to multiselect photos from ablum, force touch to preview photo, support portrait and landscape, edit photo, multiple languages(Chinese,English,Japanese)'
  s.homepage         = 'https://github.com/liuxc123/GTPhotoBrowser'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuxc123' => 'lxc_work@126.com' }
  s.source           = { :git => 'https://github.com/liuxc123/GTPhotoBrowser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GTPhotoBrowser/Classes/**/*.{h,m}'
  s.resources    = "GTPhotoBrowser/Assets/*.{png,xib,nib,bundle}"
  
  s.requires_arc = true
  s.frameworks   = 'UIKit','Photos','PhotosUI'

  s.dependency 'SDWebImage'
  s.dependency 'GPUImage'
end


