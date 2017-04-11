Pod::Spec.new do |spec|
	spec.name                 = 'CoreSDK'
	spec.version              = '0.1.4'
	spec.homepage             = 'http://documentation.emarsys.com/'
	spec.license              = 'Apache License, Version 2.0'
	spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Core iOS SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-core-sdk.git', :tag => spec.version }
	spec.source_files         = 'Core/**/*.{h,m}'
	spec.public_header_files  = [
		'Core/EMSRequestManager.h',
		'Core/EMSRequestModelBuilder.h',
		'Core/EMSRequestModel.h',
		'Core/EMSResponseModel.h',
		'Core/EMSAuthentication.h',
		'Core/EMSDeviceInfo.h',
		'Core/NSError+EMSCore.h'
	]
	spec.libraries = 'z', 'c++'
end
