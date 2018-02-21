//
//  Copyright © 2018 Emarsys. All rights reserved.
//

@import Foundation;

//! Project version number for EmarsysCore.
FOUNDATION_EXPORT double EmarsysCoreVersionNumber;

//! Project version string for EmarsysCore.
FOUNDATION_EXPORT const unsigned char EmarsysCoreVersionString[];

#import <EmarsysCore/EMSRequestManager.h>
#import <EmarsysCore/EMSRequestModelBuilder.h>
#import <EmarsysCore/EMSRequestModel.h>
#import <EmarsysCore/EMSResponseModel.h>
#import <EmarsysCore/EMSCompositeRequestModel.h>
#import <EmarsysCore/EMSRequestModelRepositoryProtocol.h>
#import <EmarsysCore/EMSRequestModelRepository.h>
#import <EmarsysCore/EMSRepositoryProtocol.h>
#import <EmarsysCore/EMSSQLSpecificationProtocol.h>
#import <EmarsysCore/EMSSQLiteHelper.h>
#import <EmarsysCore/EMSModelMapperProtocol.h>
#import <EmarsysCore/EMSRequestContract.h>
#import <EmarsysCore/EMSAuthentication.h>
#import <EmarsysCore/EMSDeviceInfo.h>
#import <EmarsysCore/NSError+EMSCore.h>
#import <EmarsysCore/EMSCoreCompletion.h>
#import <EmarsysCore/EMSRESTClient.h>
#import <EmarsysCore/EMSTimestampProvider.h>
