#import "UnityAppController.h"
#import "Unity/UnityInterface.h"

#import "UnityGameTune/UnityGameTune.h"
#import "UnityGameTune/UGTMetaData.h"

#include <string>
#include <vector>
#include <map>
#include <memory>

struct GTAlternative
{
    std::string name;
    std::vector<std::pair<std::string, std::string>> attributes;

    explicit GTAlternative(const char *_name): name(_name) {}
};


struct GTAnswer
{
    std::string identifier;
    std::string name;
    std::string type;
    GTAlternative chosenAlternative;

    GTAnswer(const char *_identifier, const char *_name, const char *_type, GTAlternative _chosenAlternative): identifier(_identifier), name(_name), type(_type), chosenAlternative(_chosenAlternative) {};
};

struct GTQuestion
{
    std::string name;
    std::string answerType;
    std::vector<GTAlternative> alternatives;

    GTQuestion(const char *_name, const char *_answerType): name(_name), answerType(_answerType) {};
};

struct GTQuestionRequest
{
    std::vector<GTQuestion> questions;
};

struct GTReward
{
    std::string name;
    std::vector<std::pair<std::string, std::string>> attributes;

    explicit GTReward(const char *_name): name(_name) {}
};

extern "C" {

    const char *UnityGameTuneCopyString(const char *string) {
        char *copy = (char *)malloc(strlen(string) + 1);
        strcpy(copy, string);
        return copy;
    }

    typedef void (*UnityGameTuneAnswerCallback)(const char *askId, const char *identifier, const char *name, const char *treatmentGroup, const char *alternativeName, const char *modelName, const char *modelVersion);
    typedef void (*UnityGameTuneEventCallback)(const char *jsonString);

    static UnityGameTuneAnswerCallback answerCallback = NULL;
    static UnityGameTuneEventCallback appStartEventCallback = NULL;
    static UnityGameTuneEventCallback useEventCallback = NULL;
    static UnityGameTuneEventCallback rewardEventCallback = NULL;
    static UnityGameTuneEventCallback questionEventCallback = NULL;
    static NSMutableDictionary *_questions;


    @interface UnityGameTuneEventListener : NSObject <UGTEventListener>

    @end

    @implementation UnityGameTuneEventListener

    - (UnityGameTuneEventListener *)init {
        self = [super init];
        return self;
    }

    - (void)onAppStartEvent:(UGTAppStartEvent *)appStartEvent {
        const char *unityProjectId = [appStartEvent.unityProjectId UTF8String];
        appStartEventCallback(unityProjectId);
    }

    - (void)onUseEvent:(UGTUseEvent *)useEvent {
        NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
        d[@"unityProjectId"] = [useEvent unityProjectId];
        d[@"answerId"] = [useEvent answerId];
        d[@"questionName"] = [useEvent questionName];
        d[@"treatmentGroup"] = [useEvent treatmentGroup];
        d[@"chosenAlternative"] = [useEvent chosenAlternative];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d options:0 error:&error];

        if (!jsonData) {
            return;
        }

        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonStringConverted = [jsonString UTF8String];
        useEventCallback(jsonStringConverted);
    }

    - (void)onRewardEvent:(UGTRewardEvent *)rewardEvent {
        NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
        d[@"unityProjectId"] = [rewardEvent unityProjectId];
        d[@"name"] = [rewardEvent name];
        d[@"attributes"] = [rewardEvent attributes];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d options:0 error:&error];

        if (!jsonData) {
            return;
        }

        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonStringConverted = [jsonString UTF8String];
        rewardEventCallback(jsonStringConverted);
    }

    - (void)onQuestionEvent:(UGTQuestionEvent *)questionEvent {
        NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
        d[@"unityProjectId"] = [questionEvent unityProjectId];
        d[@"name"] = [questionEvent name];
        d[@"answerType"] = [UGTAnswerType stringFromAnswerType:[questionEvent answerType]];
        NSMutableArray *alternatives = [[NSMutableArray alloc] init];

        for (UGTAlternative *alternative in [questionEvent alternatives]) {
            [alternatives addObject:@{ @"name": [alternative name], @"attributes": [alternative attributes] }];
        }

        d[@"alternatives"] = alternatives;
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d options:0 error:&error];

        if (!jsonData) {
            return;
        }

        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        const char *jsonStringConverted = [jsonString UTF8String];
        questionEventCallback(jsonStringConverted);
    }

    @end


    GTReward *UnityGameTuneMakeReward(const char *name)
    {
        return new GTReward(name);
    }

    void UnityGameTuneDeleteReward(GTReward *reward)
    {
        delete reward;
    }

    void UnityGameTuneAddAttributeToReward(GTReward *reward, const char *name, const char *value)
    {
        reward->attributes.push_back(std::make_pair(name, value));
    }

    void UnityGameTuneSendRewardEvent(GTReward *reward)
    {
        NSMutableDictionary *rewardEventAttributes = [[NSMutableDictionary alloc] init];

        for (const auto& rawAttribute: reward->attributes)
        {
            const char *attributeName = rawAttribute.first.c_str();
            const char *attributeValue = rawAttribute.second.c_str();
            [rewardEventAttributes setObject:[NSString stringWithUTF8String:attributeValue] forKey:[NSString stringWithUTF8String:attributeName]];
        }

        [UnityGameTune rewardEvent:[NSString stringWithUTF8String:reward->name.c_str()] withAttributes:rewardEventAttributes];
    }

    GTQuestionRequest *UnityGameTuneMakeQuestionRequest()
    {
        return new GTQuestionRequest();
    }

    void UnityGameTuneDeleteQuestionRequest(GTQuestionRequest *qRequest)
    {
        delete qRequest;
    }

    void UnityGameTuneAddQuestion(GTQuestionRequest *qRequest, const char *name, const char *answerType)
    {
        qRequest->questions.push_back(GTQuestion(name, answerType));
    }

    void UnityGameTuneAddAlternativeToLastQuestion(GTQuestionRequest *qRequest, const char *name)
    {
        qRequest->questions.back().alternatives.push_back(GTAlternative(name));
    }

    void UnityGameTuneAddAttributesToLastAlternative(GTQuestionRequest *qRequest, const char *name, const char *value)
    {
        qRequest->questions.back().alternatives.back().attributes.push_back(std::make_pair(name, value));
    }

    void UnityGameTuneInitialize(const char *projectId, const char *userId, const char *privacyConsent, int timeout, bool testMode, bool gameTuneOff, bool isEventCallbackProvided) {
        NSString *consent = [NSString stringWithUTF8String:privacyConsent];
        NSString *externalUserId = [NSString stringWithUTF8String:userId];
        UGTInitializeOptions *options = [[UGTInitializeOptions alloc] init];

        if (![consent isEqualToString:@"none"]) {
            [options setPrivacyConsent:[consent isEqualToString:@"given"]];
        }

        [options setUserId:externalUserId];
        [options setAskQuestionsTimeout:timeout];
        [options setTestMode:testMode];
        [options setGameTuneOff:gameTuneOff];

        if (!isEventCallbackProvided) {
            [UnityGameTune initialize:[NSString stringWithUTF8String:projectId] withOptions:options];
            return;
        }

        UnityGameTuneEventListener *listener = [[UnityGameTuneEventListener alloc] init];
        [UnityGameTune initialize:[NSString stringWithUTF8String:projectId] withOptions:options withEventListener:listener];
    }

    bool UnityGameTuneGetDebugMode() {
        return [UnityGameTune getDebugMode];
    }

    void UnityGameTuneSetDebugMode(bool debugMode) {
        [UnityGameTune setDebugMode:debugMode];
    }

    bool UnityGameTuneIsSupported() {
        return [UnityGameTune isSupported];
    }

    bool UnityGameTuneIsReady() {
        return [UnityGameTune isReady];
    }

    const char * UnityGameTuneGetVersion() {
        return UnityGameTuneCopyString([[UnityGameTune getVersion] UTF8String]);
    }

    bool UnityGameTuneIsInitialized() {
        return [UnityGameTune isInitialized];
    }

    void UnityGameTuneSetMetaData(const char *category, const char * data) {
        if(category != NULL && data != NULL) {
            UGTMetaData *metaData = [[UGTMetaData alloc] initWithCategory:[NSString stringWithUTF8String:category]];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[[NSString stringWithUTF8String:data] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            for(id key in json) {
                [metaData set:key value:[json objectForKey:key]];
            }
            [metaData commit];
        }
    }

    void UnityGameTuneSetAnswerCallback(UnityGameTuneAnswerCallback callback) {
        answerCallback = callback;
    }

    void UnityGameTuneSetAppStartEventCallback(UnityGameTuneEventCallback callback) {
        appStartEventCallback = callback;
    }

    void UnityGameTuneSetUseEventCallback(UnityGameTuneEventCallback callback) {
        useEventCallback = callback;
    }

    void UnityGameTuneSetRewardEventCallback(UnityGameTuneEventCallback callback) {
        rewardEventCallback = callback;
    }

    void UnityGameTuneSetQuestionEventCallback(UnityGameTuneEventCallback callback) {
        questionEventCallback = callback;
    }

    void UnityGameTuneAskQuestions(const char *askId, GTQuestionRequest *request) {
        size_t requestSize = request->questions.size();
        NSMutableArray *questionsArray = [[NSMutableArray alloc] initWithCapacity:requestSize];

        NSString *askIdString = [NSString stringWithUTF8String:askId];

        for (const auto& rawQuestion: request->questions)
        {
            const char *questionName = rawQuestion.name.c_str();
            const char *answerType = rawQuestion.answerType.c_str();
            size_t alternativesSize = rawQuestion.alternatives.size();
            NSMutableArray *alternativesArray = [[NSMutableArray alloc] initWithCapacity:alternativesSize];

            for (const auto& rawAlternative: rawQuestion.alternatives)
            {
                const char *rawAlternativeName = rawAlternative.name.c_str();
                UGTAlternative *alternative = [[UGTAlternative alloc] initWithName:[NSString stringWithUTF8String:rawAlternativeName]];

                for (const auto& rawAttributePair: rawAlternative.attributes)
                {
                    const char *rawAttributeName = rawAttributePair.first.c_str();
                    const char *rawAttributeValue = rawAttributePair.second.c_str();
                    [alternative addAttribute:[NSString stringWithUTF8String:rawAttributeValue] forKey:[NSString stringWithUTF8String:rawAttributeName]];
                }

                [alternativesArray addObject:alternative];
            }

            UnityGameTuneAnswerType type;
            type = kUnityGameTuneAnswerTypeNewUntilUsed;
            if (strcmp(answerType, "ALWAYS_NEW") == 0) {
                type = kUnityGameTuneAnswerTypeAlwaysNew;
            }

            UGTQuestion *question = [UnityGameTune createQuestion:[NSString stringWithUTF8String:questionName] alternatives:alternativesArray answerType:type handler:^(UGTAnswer *answer) {
                const char *answerId = [answer.identifier UTF8String];
                const char *answerName = [answer.name UTF8String];
                const char *treatmentGroup = [answer.treatmentGroup UTF8String];
                const char *alternativeName = [answer.chosenAlternative.name UTF8String];
                const char *askGuid = [askIdString UTF8String];
                const char *modelName = [answer.modelName UTF8String];
                const char *modelVersion = [answer.modelVersion UTF8String];
                answerCallback(askGuid, answerId, answerName, treatmentGroup, alternativeName, modelName, modelVersion);
            }];

            [questionsArray addObject:question];
        }

        [UnityGameTune askQuestionsWithArray:questionsArray];
    }

    void UnityGameTuneUse(const char *answerId, const char *questionName, const char *chosenAlternativeName) {
        if (strlen(answerId) == 0) {
            // create dummy question to send Use event
            UGTQuestion *dummyQuestion = [UnityGameTune createQuestion:[NSString stringWithUTF8String:questionName] alternatives:@[@"dummy1", @"dummy2"] handler:^(UGTAnswer *answer) {}];
            [dummyQuestion use:[NSString stringWithUTF8String:chosenAlternativeName]];
            return;
        }

        UGTAlternative *chosenAlternative = [[UGTAlternative alloc] initWithName:[NSString stringWithUTF8String:chosenAlternativeName]];
        UGTAnswer *answer = [[UGTAnswer alloc] initWithIdentifier:[NSString stringWithUTF8String:answerId] name:[NSString stringWithUTF8String:questionName] group:@"" chosenAlternative:chosenAlternative];
        [answer use];
    }

    void UnityGameTuneSetUserAttribute(const char *name, const char *value) {
        [UnityGameTune setUserAttribute:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:name]];
    }

    void UnityGameTuneSetPrivacyConsent(bool consent) {
        [UnityGameTune setPrivacyConsent:consent? YES: NO];
    }
}
