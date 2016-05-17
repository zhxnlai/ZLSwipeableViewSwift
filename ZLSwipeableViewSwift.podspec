Pod::Spec.new do |s|
  s.name         = "ZLSwipeableViewSwift"
  s.version      = "0.0.7"
  s.summary      = "A simple view for building card like interface like Tinder and Potluck."
  s.description  = <<-DESC
                  ZLSwipeableViewSwift is a simple view for building card like interface like Tinder and Potluck.
                   DESC
  s.homepage     = "https://github.com/zhxnlai/ZLSwipeableViewSwift"
  s.screenshots  = "https://github.com/zhxnlai/ZLSwipeableViewSwift/raw/master/Previews/animation.gif", "https://github.com/zhxnlai/ZLSwipeableViewSwift/raw/master/Previews/swipe.gif", "https://github.com/zhxnlai/ZLSwipeableViewSwift/raw/master/Previews/direction.gif", "https://github.com/zhxnlai/ZLSwipeableViewSwift/raw/master/Previews/undo.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Zhixuan Lai" => "zhxnlai@gmail.com" }
  s.social_media_url   = "http://twitter.com/ZhixuanLai"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/zhxnlai/ZLSwipeableViewSwift.git", :tag => "0.0.7" }
  s.source_files  = "ZLSwipeableViewSwift/*.swift"

  s.framework  = "UIKit"

  s.requires_arc = true
end
