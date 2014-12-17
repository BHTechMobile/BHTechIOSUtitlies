//
//  DropboxServices.m
//
//

#import "DropboxServices.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxServices ()<DBSessionDelegate,DBRestClientDelegate>{
    NSString* _appKey;
    NSString* _appSecret;
    NSString* _root;
    DropboxServicesBasicBlock _initSessionSuccessBlock;
    DropboxServicesFailureBlock _initSessionfailureBlock;
    
    DropboxServicesSuccessBlock _browseListSuccessBlock;
    DropboxServicesFailureBlock _browseListFailureBlock;

    DropboxServicesSuccessBlock _uploadFileSuccessBlock;
    DropboxServicesFailureBlock _uploadFileFailureBlock;

    DropboxServicesSuccessBlock _downloadFileSuccessBlock;
    DropboxServicesFailureBlock _downloadFileFailureBlock;

    DBRestClient* _restClient;
}

@end

@implementation DropboxServices

+ (id)sharedServices{
    static DropboxServices * services;
    if (!services) {
        services = [[DropboxServices alloc] init];
    }
    return services;
}

- (id)init{
    self = [super init];
    if (self) {
        _appKey = @"vb7twspykxs3p48";
        _appSecret = @"4ovk6jopj3dmhaz";
        _root = kDBRootAppFolder;
        DBSession* session = [[DBSession alloc] initWithAppKey:_appKey appSecret:_appSecret root:_root];
        session.delegate = self;
        [DBSession setSharedSession:session];

    }
    return self;
}

- (void)startSessionFromViewController:(UIViewController*)viewController success:(DropboxServicesBasicBlock)success failure:(DropboxServicesFailureBlock)failure{
    if ([[DBSession sharedSession] isLinked]) {
        success();
    }
    else{
        _initSessionSuccessBlock = success;
        _initSessionfailureBlock = failure;
        [[DBSession sharedSession] linkFromController:viewController];
    }
}

- (void)unlink{
    [[DBSession sharedSession] unlinkAll];
}

- (void)browseListPhotosSuccess:(DropboxServicesSuccessBlock)success failure:(DropboxServicesFailureBlock)failure{
    _browseListSuccessBlock = success;
    _browseListFailureBlock = failure;
    [_restClient loadMetadata:@"/"];
    
}

- (void)uploadPhotosAtPath:(NSString*)localPath success:(DropboxServicesSuccessBlock)success failure:(DropboxServicesFailureBlock)failure progress:(DropboxServicesProgressBlock)progress{
    _uploadFileSuccessBlock = success;
    _uploadFileFailureBlock = failure;
    [_restClient uploadFile:[localPath lastPathComponent] toPath:@"/" withParentRev:nil fromPath:localPath];
}

- (void)downloadPhoto:(NSString*)filePath success:(DropboxServicesSuccessBlock)success failure:(DropboxServicesFailureBlock)failure progress:(DropboxServicesProgressBlock)progress{
    _downloadFileSuccessBlock = success;
    _downloadFileFailureBlock = failure;
    [_restClient loadThumbnail:filePath ofSize:@"iphone_bestfit" intoPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[filePath lastPathComponent]]];
}

#pragma mark - Dropbox Session Delegate

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId{
    if (_initSessionfailureBlock) {
        _initSessionfailureBlock(nil);
    }
}

#pragma mark - Dropbox Session Handler

- (void)updateSessionBlocks{
    if ([[DBSession sharedSession] isLinked]) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
        if (_initSessionSuccessBlock) {
            _initSessionSuccessBlock();
        }
    }
    else{
        if (_initSessionfailureBlock) {
            _initSessionfailureBlock(nil);
        }
    }
}

#pragma mark - Rest Client Delegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSMutableArray * result = [NSMutableArray new];
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
            [result addObject:file.path];
        }
        if (_browseListSuccessBlock) {
            _browseListSuccessBlock(result);
        }
    }
    else{
        if (_browseListFailureBlock) {
            _browseListFailureBlock(nil);
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
    if (_browseListFailureBlock) {
        _browseListFailureBlock(error);
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    if (_uploadFileSuccessBlock) {
        _uploadFileSuccessBlock(metadata.path);
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
    if (_uploadFileFailureBlock) {
        _uploadFileFailureBlock(error);
    }
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
    if (_downloadFileSuccessBlock) {
        _downloadFileSuccessBlock([UIImage imageWithContentsOfFile:destPath]);
    }
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    if (_downloadFileFailureBlock) {
        _downloadFileFailureBlock(error);
    }
}




@end
