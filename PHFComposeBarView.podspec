Pod::Spec.new do |s|
  s.name           = 'PHFComposeBarView'
<<<<<<< HEAD
  s.version        = '1.2.3'
  s.summary        = 'A precise reconstruction of the compose bar from iOS Messages.app.'
=======
  s.version        = '2.0.0'
  s.summary        = 'A precise reconstruction of the compose bar from iOS 7 Messages.app.'
>>>>>>> 4b0c7066cc659a28f5552954aee9bec6df785518
  s.description    = <<-DESC
The compose bar from the messages application on iOS is often replicated in
applications, mostly with slightly different visuals and behavior. This class is
an exact reconstruction of the compose bar and behaves exactly like it. It is
configurable in terms of maximium height the input view can grow. By specifying
a maximum text length a counter is shown, similar to composing an SMS. You can
also specify an image for the utility button on the left of the input which
causes that button to become visible. Further, the color of the send button can
be customized.
                     DESC
  s.homepage       = 'https://github.com/fphilipe/PHFComposeBarView'
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
<<<<<<< HEAD
  s.author         = { 'Philipe Fatio' => 'me@phili.pe',
                       'Anton Bukov' => 'k06aaa@gmail.com' }
  s.source         = { :git => 'https://github.com/fphilipe/PHFComposeBarView.git', :tag => 'v1.2.3' }
=======
  s.author         = { 'Philipe Fatio' => 'me@phili.pe' }
  s.source         = { :git => 'https://github.com/fphilipe/PHFComposeBarView.git', :tag => 'v2.0.0' }
>>>>>>> 4b0c7066cc659a28f5552954aee9bec6df785518
  s.source_files   = 'Classes/*'
  s.preserve_paths = 'LICENSE', 'README.md'
  s.requires_arc   = true
  s.platform       = :ios
  s.ios.deployment_target = '7.0'
  s.screenshots    = %w[
https://raw.github.com/fphilipe/PHFComposeBarView/v2.0.0/Screenshots/demo.gif
https://raw.github.com/fphilipe/PHFComposeBarView/v2.0.0/Screenshots/empty.png
https://raw.github.com/fphilipe/PHFComposeBarView/v2.0.0/Screenshots/text.png
                     ]

  s.dependency 'PHFDelegateChain', '~> 1.0'
end
