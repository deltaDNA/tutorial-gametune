#import "UGTAnswer.h"

@interface UGTUseEvent : NSObject

@property (nonatomic, strong, readonly) NSString *unityProjectId;
@property (nonatomic, strong, readonly) NSString *answerId;
@property (nonatomic, strong, readonly) NSString *questionName;
@property (nonatomic, strong, readonly) NSString *treatmentGroup;
@property (nonatomic, strong, readonly) NSString *chosenAlternative;

@end
