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
    Inherits DvtkHighLevelInterface.Dicom.Threads.DicomThread

    'has a scenariorunner
    Protected m_scenarioRunner As ScenarioRunner

    'Constructor
    Public Sub New()
        'We want to report all messages on the same thread, therefor the Reporter needs TestTool object
        'Reporter can than call the methods: WriteErrorNow(), WriteWarningNow() and WriteInformationNow()
        Reporter.GetInstance.SetTestTool(Me)
        m_scenarioRunner = New ScenarioRunner()
    End Sub

    Protected Overrides Sub Execute()

        'run scenario
        m_scenarioRunner.RunScenario(New ArchiveScenario3())
    End Sub

    Public Sub WriteErrorNow(ByVal errorText As String)
        WriteError(errorText)
    End Sub

    Public Sub WriteWarningNow(ByVal warningText As String)
        WriteWarning(warningText)
    End Sub

    Public Sub WriteInformationNow(ByVal informationText As String)
        WriteInformation(informationText)
    End Sub

End Class


'Implementation of the main function of DVTk scripts
Module DvtkScript
    ' Entry point of this Visual Basic Script.
    Sub Main(ByVal CmdArgs() As String)

        Dim theExecutablePath As String = System.Windows.Forms.Application.ExecutablePath
        Dim theExecutableName As String = Path.GetFileName(theExecutablePath).ToLower()

#If Not DVT_INTERPRETS_SCRIPT Then
        Dvtk.Setup.Initialize()
#End If
        'create threadmanager
        Dim theDvtThreadManager As DvtkHighLevelInterface.Common.Threads.ThreadManager = New DvtkHighLevelInterface.Common.Threads.ThreadManager
        'Test tool configuration initialisation
        Dim sessionFileName As String
        Dim testtoolconfig As TestToolConfiguration = TestToolConfiguration.GetInstance()
        'Determine the session file aqnd path name
#If DVT_INTERPRETS_SCRIPT Then
		sessionFilename = Session.SessionFileName
#Else
        sessionFileName = "D:\IHE_RO2008\03-Code\DVtkProject\Sessionfiles.ses"
#End If
        'initialise test tool configuration
        testtoolconfig.Initialise(Path.GetDirectoryName(sessionFileName))

        'creation test tool object
        Dim theTestTool As TestTool = New TestTool()
        theTestTool.Initialize(theDvtThreadManager)
        theTestTool.Options.LogWaitingForCompletionChildThreads = False

        'reset the hli activity form window
        HliForm.ResetSingleton()

        'set the test tool properties
#If DVT_INTERPRETS_SCRIPT Then
        theTestTool.Options.DvtkScriptSession = Session
        theTestTool.Options.StartAndStopResultsGatheringEnabled= False
        theTestTool.ResultsGatheringStarted = True
        theTestTool.Options.Identifier = Path.GetFileName(DvtkScriptHostScriptFullFileName).Replace(".", "_")
#Else
        theTestTool.Options.StartAndStopResultsGatheringEnabled = True
        theTestTool.ResultsGatheringStarted = False
        theTestTool.Options.LoadFromFile(sessionFileName)
        'theTestTool.Options.ShowResults = True
        HliForm.GetSingleton().AutoExit = True
        theTestTool.Options.Identifier = "TestTool_vbs"
#End If
        testToolConfig.SetMainThread(theTestTool)
        testToolConfig.SetSession(theTestTool.Options.DvtkScriptSession)
        testToolConfig.SetThreadManager(theDvtThreadManager)

        'start the test tool thread
        theTestTool.Start()
        'wait for the test tool object to finish
        theDvtThreadManager.WaitForCompletionThreads()

#If Not DVT_INTERPRETS_SCRIPT Then
        Dvtk.Setup.Terminate()
#End If
    End Sub 'Main
End Module ' DvtkScript
