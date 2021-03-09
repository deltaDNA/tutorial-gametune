using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DeltaDNA;
using UnityEngine.GameTune;
using UnityEngine.UI;

public class DeltaDNAManager : MonoBehaviour
{
    public InputField missionIDInput;

    // Start is called before the first frame update
    void Start()
    {
        DDNA.Instance.SetLoggingLevel(DeltaDNA.Logger.Level.DEBUG);
        DDNA.Instance.ClientVersion = "1.0.0";

        DDNA.Instance.Settings.DefaultGameParameterHandler = new GameParametersHandler(gameParameters => {
            ParameterHandler(gameParameters);
        });

        //Start the deltaDNA SDK, if it isn't already running
        if (!DDNA.Instance.HasStarted)
        {
            DDNA.Instance.SetLoggingLevel(DeltaDNA.Logger.Level.DEBUG);
            DDNA.Instance.StartSDK();
        }
    }

    //Clicking this button will record a missionFailed event
    //This may trigger a campaign
    public void onMissionFailedClick()
    {
        // Create a missionCompleted event object
        GameEvent missionFailEvent;

        //if there is not input in the text box, set the missionID parameter to a default 3
        if (string.IsNullOrEmpty(missionIDInput.text)) { 
            missionFailEvent = new GameEvent("missionFailed")
                                .AddParam("missionID", 3)
                                .AddParam("isTutorial", false)
                                .AddParam("userLevel", 5)
                                .AddParam("userXP", 50);
        } else
        {
        missionFailEvent = new GameEvent("missionFailed")
                            .AddParam("missionID", missionIDInput.text)
                            .AddParam("isTutorial", false)
                            .AddParam("userLevel", 5)
                            .AddParam("userXP", 50);
        }

        //Record missionCompleted event and wire up handler callbacks
        DDNA.Instance.RecordEvent(missionFailEvent).Run();
    }
    private void ParameterHandler(Dictionary<string, object> gameParameters)
    {
        //Use the game parameters received from DeltaDNA as a userAttribute to send to GameTune
        Dictionary<string, object> userAttributes = new Dictionary<string, object>()
        {
            {"lastMission", gameParameters["missionName"]}
        };

        //Set the userAttributes so that they are sent with the next question
        GameTune.SetUserAttributes(userAttributes);

        // Create a GameTune question to ask if the user should get a low, medium or high promotion offer
        Question iapQuestion = GameTune.CreateQuestion(
            "iap_offer",
            new string[] { "medium", "high", "low" },
            GameTuneManager.IAPOfferHandler
        );

        //Ask the GameTune question
        GameTune.AskQuestions(iapQuestion);
    }
}


