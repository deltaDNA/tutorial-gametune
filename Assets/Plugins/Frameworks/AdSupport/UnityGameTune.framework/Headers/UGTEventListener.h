#import "UGTAppStartEvent.h"
#import "UGTUseEvent.h"
#import "UGTRewardEvent.h"
#import "UGTQuestionEvent.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UGTEventListener<NSObject>

- (void)onAppStartEvent:(UGTAppStartEvent *)appStartEvent;

- (void)onUseEvent:(UGTUseEvent *)useEvent;

- (void)onRewardEvent:(UGTRewardEvent *)rewardEvent;

- (void)onQuestionEvent:(UGTQuestionEvent *)questionEvent;

@end

NS_ASSUME_NONNULL_END
