using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.GameTune;
using DeltaDNA;


public class GameTuneManager : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        // Create a GameTune initialisation option object
        InitializeOptions options = new InitializeOptions();

        //Sets the privacy consent to true
        //Only do this if your user has given permission
        options.SetPrivacyConsent(true);   

        //Start the GameTune SDK with options
        GameTune.Initialize("8082331b-104e-41e7-a355-3a8ce73116ab", options);

        // Create a GameTune question to ask if the user should get a low, medium or high difficulty ramp up
        Question difficultyQuestion = GameTune.CreateQuestion(
            "test_q",
            new string[] { "middle", "up", "down" },
            DifficultyRampHandler
        );

        //Ask the GameTune question
        GameTune.AskQuestions(difficultyQuestion);
    }

    //Handle the answer returned by GameTune for the difficulty ramp question
    private void DifficultyRampHandler(Answer answer)
    {
        //Create a game event to send the answer to DeltaDNA
        GameEvent gtAnswerUsedEvent;

        //Model name and model version only exist if the treatment group is "ml"
        if (answer.TreatmentGroup == "ml")
        {
            gtAnswerUsedEvent = new GameEvent("gameTuneAnswerUsed")
                .AddParam("gtAnswerID", answer.Id)
                .AddParam("gtAnswerTreatmentGroup", answer.TreatmentGroup)
                .AddParam("gtAnswerValue", answer.Value)
                .AddParam("gtModelVersion", answer.ModelVersion);
        }
        else
        {
            gtAnswerUsedEvent = new GameEvent("gameTuneAnswerUsed")
                .AddParam("gtAnswerID", answer.Id)
                .AddParam("gtAnswerTreatmentGroup", answer.TreatmentGroup)
                .AddParam("gtAnswerValue", answer.Value);
        }

        //Record missionCompleted event and wire up handler callbacks
        DDNA.Instance.RecordEvent(gtAnswerUsedEvent);

        //Handle different answer values
        if (answer.Value == "down")
        {
            Debug.Log("Difficulty ramp is SLOW");
        }
        else if (answer.Value == "middle")
        {
            Debug.Log("Difficulty ramp is NORMAL");
        }
        else
        {
            Debug.Log("Difficulty ramp is FAST");
        }

        //Mark the answer as used
        answer.Use();
    }

    //Handle the answer returned by GameTune for the IAP promotion question
    public static void IAPOfferHandler(Answer answer)
    {
        //Create a game event to send the answer to DeltaDNA
        GameEvent gtAnswerUsedEvent;

        //Model name and model version only exist if the treatment group is "ml"
        if (answer.TreatmentGroup == "ml")
        {
            gtAnswerUsedEvent = new GameEvent("gameTuneAnswerUsed")
                .AddParam("gtAnswerID", answer.Id)
                .AddParam("gtAnswerTreatmentGroup", answer.TreatmentGroup)
                .AddParam("gtAnswerValue", answer.Value)
               
                .AddParam("gtModelVersion", answer.ModelVersion);
        }
        else
        {
            gtAnswerUsedEvent = new GameEvent("gameTuneAnswerUsed")
                .AddParam("gtAnswerID", answer.Id)
                .AddParam("gtAnswerTreatmentGroup", answer.TreatmentGroup)
                .AddParam("gtAnswerValue", answer.Value);
        }

        //Record missionCompleted event and wire up handler callbacks
        DDNA.Instance.RecordEvent(gtAnswerUsedEvent);

        //Handle different answer values
        if(answer.Value == "low")
        {
            Debug.Log("Promo IAP costs $0.99");
        } else if (answer.Value == "medium")
        {
            Debug.Log("Promo IAP costs $4.99");
        } else
        {
            Debug.Log("Promo IAP costs $9.99");
        }

        //Mark the answer as used
        answer.Use();
    }
}