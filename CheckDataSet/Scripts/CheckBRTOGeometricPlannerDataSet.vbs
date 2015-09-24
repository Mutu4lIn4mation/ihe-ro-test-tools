#If RUN_UNDER_VISUALSTUDIO Then
' Indicates if this Visual Basic Script will be executed under DVT.
#Const DVT_INTERPRETS_SCRIPT = False
#Else
#Const DVT_INTERPRETS_SCRIPT = True
#End If

#If DVT_INTERPRETS_SCRIPT Then
#include "Includes.vbc"
#End If

'Test tool class, this class runs IHE-RO scenario's and generates results files
Class TestTool
Inherits TestToolBase
    'has a scenariorunner
    Protected m_scenarioRunner As ScenarioRunner
    Protected m_mediaSession as Dvtk.Sessions.MediaSession

    'Constructor
    Public Sub New(ByVal mediaSession As Dvtk.Sessions.MediaSession)
        'We want to report all messages on the same thread, therefor the Reporter needs TestTool object
        'Reporter can than call the methods: WriteErrorNow(), WriteWarningNow() and WriteInformationNow()
        Reporter.GetInstance.SetTestTool(Me)
        
        m_scenarioRunner = New ScenarioRunner()
        m_mediaSession = mediaSession
    End Sub

    Protected Overrides Sub Execute()
        
        'ValidateMessages()

        'run scenario
        m_scenarioRunner.RunScenario(New CheckBRTOGeometricPlannerDataSet(m_mediaSession))
    End Sub


End Class


'Implementation of the main function of DVTk scripts
Module DvtkScript
    ' Entry point of this Visual Basic Script.
    Sub Main(ByVal CmdArgs() As String)




        Dim mediaSession as Dvtk.Sessions.MediaSession
        Dim sessionFileName As String

        'create threadmanager
        Dim theDvtThreadManager As DvtkHighLevelInterface.Common.Threads.ThreadManager = New DvtkHighLevelInterface.Common.Threads.ThreadManager

        Dim testtoolconfig As TestToolConfiguration = TestToolConfiguration.GetInstance()
        


        'Determine the session file aqnd path name
#If DVT_INTERPRETS_SCRIPT Then



		mediaSession =  Dvtk.Sessions.MediaSession.LoadFromFile("..\Sessionfiles\TestTool session - DataSetCheck.ses")
        sessionFileName = "..\Sessionfiles\TestTool script - DataSetCheck.ses"

        'delete current result files
        Dim fileInfo As IO.FileInfo
        Dim dirInfo As New IO.DirectoryInfo("..\ResultDicomValidation")
        For Each fileInfo In dirInfo.GetFiles()
                fileInfo.Delete()
        Next

#Else
        mediaSession =  Dvtk.Sessions.MediaSession.LoadFromFile("..\..\..\..\DVtkProject\CheckDataSet\Sessionfiles\TestTool session - DataSetCheck - Test.ses")
        sessionFileName = "..\..\..\..\DVtkProject\CheckDataSet\Sessionfiles\TestTool script - DataSetCheck - Test.ses"
#End If

        testtoolconfig.Initialise(System.IO.Path.GetDirectoryName(sessionFileName))



#If Not DVT_INTERPRETS_SCRIPT Then
        Dvtk.Setup.Initialize()
#End If
        
        
        Dim theTestTool As TestTool = New TestTool(mediaSession)

        theTestTool.Initialize(theDvtThreadManager)
        theTestTool.Options.LogWaitingForCompletionChildThreads = False

        'reset the hli activity form window
        DvtkHighLevelInterface.common.userinterfaces.HliForm.ResetSingleton()

#If DVT_INTERPRETS_SCRIPT Then
        theTestTool.Options.DvtkScriptSession = Session
        theTestTool.Options.StartAndStopResultsGatheringEnabled= False
        theTestTool.ResultsGatheringStarted = True
        theTestTool.Options.Identifier = Path.GetFileName(DvtkScriptHostScriptFullFileName).Replace(".", "_")
'#Else
'        theTestTool.Options.StartAndStopResultsGatheringEnabled = True
'        theTestTool.ResultsGatheringStarted = False
'        theTestTool.Options.LoadFromFile(sessionFileName)
'        'theTestTool.Options.ShowResults = True
'        DvtkHighLevelInterface.common.userinterfaces.HliForm.GetSingleton().AutoExit = True
'        theTestTool.Options.Identifier = "TestTool_vbs"
#End If

        testToolConfig.SetMainThread(theTestTool)
        testToolConfig.SetSession(theTestTool.Options.DvtkScriptSession)
        testToolConfig.SetThreadManager(theDvtThreadManager)

'start the test tool thread
        theTestTool.Start()

        'wait for the test tool object to finish
        theDvtThreadManager.WaitForCompletionThreads()

         If( IO.File.Exists("..\ResultDicomValidation\Summary_CustomDatasetValidation.html"))
            Dim readText As String = IO.File.ReadAllText("..\ResultDicomValidation\Summary_CustomDatasetValidation.html")
            theTestTool.WriteHtml(readText, False, True)
        End If

#If Not DVT_INTERPRETS_SCRIPT Then
        Dvtk.Setup.Terminate()
#End If
    End Sub 'Main
End Module ' DvtkScript
