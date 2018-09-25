
Pod::Spec.new do |s|

    s.name         = "FQ_MineScrollerVC"

    s.version      = "0.0.7"

    s.summary      = "快捷创建多标题以及多控制器协同侧滑的控制器"

    s.homepage              = 'https://github.com/FQDEVER/FQ_MineScrollerVC'

    s.license                    = { :type => 'MIT', :file => 'LICENSE' }

    s.author                     = { 'FQDEVER' => '814383466@qq.com' }

    s.source                     = { :git => 'https://github.com/FQDEVER/FQ_MineScrollerVC.git', :tag => s.version }

    s.source_files               = 'FQ_MineScrollerVC/*.{h,m}'

    s.platform                   = :ios

    s.ios.deployment_target      = '8.0'

end
