using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DeltaDNA;
using UnityEngine.GameTune;

public class DeltaDNAManager : MonoBehaviour
{
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
	
    //Clicking this button will record a missionCompleted event
    //This may trigger a campaign
    public void onMissionCompletedClick()
    {
        // Create a missionCompleted event object
        GameEvent missionCompEvent = new GameEvent("missionCompleted")
            .AddParam("missionID", 3)
            .AddParam("missionName", "Chapter 1 Mission 3")
            .AddParam("isTutorial", false)
            .AddParam("userLevel", 5)
            .AddParam("userXP", 50);
        //Record missionCompleted event and wire up handler callbacks
        DDNA.Instance.RecordEvent(missionCompEvent).Run();
    }
    private void ParameterHandler(Dictionary<string, object> gameParameters)
    {
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
