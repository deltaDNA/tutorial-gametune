@interface UGTInitializeOptions : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic) int askQuestionsTimeout;
@property (nonatomic, strong, readonly) NSString *privacyConsent;
@property (nonatomic) BOOL testMode;
@property (nonatomic) BOOL gameTuneOff;

- (UGTInitializeOptions *)init;

- (void)setPrivacyConsent:(BOOL)given;

@end
