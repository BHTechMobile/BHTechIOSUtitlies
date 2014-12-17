//
//  Services.h
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^DropboxServicesBasicBlock)(void);
typedef void (^DropboxServicesSuccessBlock)(id response);
typedef void (^DropboxServicesFailureBlock)(NSError* error);
typedef void (^DropboxServicesProgressBlock)(unsigned long long size, unsigned long long total);

@interface DropboxServices : NSObject

+ (id)sharedServices;

//Session
- (void)startSessionFromViewController:(UIViewController*)viewController success:(DropboxServicesBasicBlock)success failure:(DropboxServicesFailureBlock)failure;
- (void)unlink;
- (void)updateSessionBlocks;

//Upload Download

- (void)browseListPhotosSuccess:(DropboxServicesSuccessBlock)success failure:(DropboxServicesFailureBlock)failure;
- (void)uploadPhotosAtPath:(NSString*)localPath success:(DropboxServicesSuccessBlock)success failure:(DropboxServicesFailureBlock)failure progress:(DropboxServicesProgressBlock)progress;
- (void)downloadPhoto:(NSString*)fileName success:(DropboxServicesSuccessBlock)success failure:(DropboxServicesFailureBlock)failure progress:(DropboxServicesProgressBlock)progress;

@end
