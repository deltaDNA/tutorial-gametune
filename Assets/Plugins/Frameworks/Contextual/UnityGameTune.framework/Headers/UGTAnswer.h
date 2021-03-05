#import "UGTAlternative.h"

@interface UGTAnswer : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *treatmentGroup;
@property (nonatomic, strong, readonly) UGTAlternative *chosenAlternative;
@property (nonatomic, strong, readonly) NSString *modelName;
@property (nonatomic, strong, readonly) NSString *modelVersion;

- (UGTAnswer *)initWithIdentifier:(NSString *)identifier name:(NSString *)name group:(NSString *)treatmentGroup
    chosenAlternative:(UGTAlternative *)chosenAlternative;

- (UGTAnswer *)initWithIdentifier:(NSString *)identifier name:(NSString *)name group:(NSString *)treatmentGroup
    chosenAlternative:(UGTAlternative *)chosenAlternative modelName:(NSString *)modelName modelVersion:(NSString *)modelVersion;

- (void)use;

@end
