@interface UGTRewardEvent : NSObject

@property (nonatomic, strong, readonly) NSString *unityProjectId;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *attributes;

@end
