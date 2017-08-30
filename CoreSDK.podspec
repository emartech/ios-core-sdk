Pod::Spec.new do |spec|
	spec.name                 = 'CoreSDK'
	spec.version              = '0.9.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
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
		'Core/NSError+EMSCore.h',
        'Core/EMSCoreCompletion.h',
        'Core/Worker/EMSRESTClient.h'
	]
	spec.libraries = 'z', 'c++', 'sqlite3'
end