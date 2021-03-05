#import "UGTAnswerType.h"

@interface UGTQuestionEvent : NSObject

@property (nonatomic, strong, readonly) NSString *unityProjectId;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSMutableArray *alternatives;
@property (nonatomic) UnityGameTuneAnswerType answerType;

@end
