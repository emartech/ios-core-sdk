Pod::Spec.new do |spec|
	spec.name                 = 'CoreSDK'
	spec.version              = '1.7.2'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002683889'
	spec.license              = 'Mozilla Public License 2.0'
	spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Core iOS SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-core-sdk.git', :tag => spec.version }
	spec.source_files         = 'Core/**/*.{h,m}'
	spec.public_header_files  = [        
	        'Core/EMSRequestManager.h',
                'Core/Models/EMSRequestModelBuilder.h',
                'Core/Models/EMSRequestModel.h',
                'Core/Models/EMSResponseModel.h',
                'Core/Models/EMSCompositeRequestModel.h',
                'Core/Repository/RequestModel/EMSRequestModelRepositoryProtocol.h',
                'Core/Repository/RequestModel/EMSRequestModelRepository.h',
                'Core/Repository/Log/EMSLogRepositoryProtocol.h',
                'Core/Repository/Log/EMSLogHandlerProtocol.h',
                'Core/Repository/EMSRepositoryProtocol.h',
                'Core/Repository/EMSSQLSpecificationProtocol.h',
                'Core/Database/EMSSQLiteHelper.h',
                'Core/Database/EMSModelMapperProtocol.h',
                'Core/Database/EMSRequestContract.h',
                'Core/Log/EMSLogger.h',
                'Core/Log/EMSLoggerSettings.h',
                'Core/Categories/NSError+EMSCore.h',
                'Core/Categories/NSDate+EMSCore.h',
                'Core/Categories/NSDictionary+EMSCore.h',
                'Core/Validators/EMSDictionaryValidator.h',
                'Core/EMSAuthentication.h',
                'Core/EMSDeviceInfo.h',
                'Core/EMSCoreCompletion.h',
                'Core/Worker/EMSRESTClient.h',
                'Core/Providers/EMSTimestampProvider.h',
                'Core/Providers/EMSUUIDProvider.h'
	]
	spec.libraries = 'z', 'c++', 'sqlite3'
end