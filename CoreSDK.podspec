Pod::Spec.new do |spec|
	spec.name                 = 'CoreSDK'
	spec.version              = '1'
	spec.homepage             = 'http://documentation.emarsys.com/'
	spec.license              = 'Apache License, Version 2.0'
	spec.author               = { 'Scarab Research Ltd.' => 'dev@scarabresearch.com' }
	spec.summary              = 'Core iOS SDK'
	spec.platform             = :ios, '8.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-core-sdk.git', :tag => '1' }
	spec.source_files         = 'Core/**/*.{h,m}'
	spec.public_header_files  = [
		'Core/EMSRequestManager.h',
		'Core/EMSRequestModelBuilder.h',
		'Core/EMSRequestModel.h',
		'Core/NSString+EMSCore.h'
	]
	spec.libraries = 'z', 'c++'
end
