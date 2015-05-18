#If RUN_UNDER_VISUALSTUDIO Then
' Indicates if this Visual Basic Script will be executed under DVT.
#Const DVT_INTERPRETS_SCRIPT = False
#Else
#Const DVT_INTERPRETS_SCRIPT = True
#End If

#If DVT_INTERPRETS_SCRIPT Then
#include "Includes.vbc"
#End If

'TDW Test tool implementation
Class TestTool
    Inherits TestToolBase

    'Constructor
    Public Sub New()
        'We want to report all messages on the same thread, therefor the Reporter needs TestTool object
        'Reporter can than call the methods: WriteErrorNow(), WriteWarningNow() and WriteInformationNow()
        Reporter.GetInstance.SetTestTool(Me)
        m_scenarioRunner = New ScenarioRunner()
    End Sub

    Protected Overrides Sub Execute()

        'run scenario
        m_scenarioRunner.RunScenario(New QCROutputObjectsRetrievalScenario())

    End Sub

End Class

'Implementation of the main function of DVTk scripts
Module DvtkScript

    ' Entry point of this Visual Basic Script.
    Sub Main(ByVal CmdArgs() As String)

        TesttoolRunner.RunTool(New TestTool(), TesttoolRunner.TestSessionFileName_QAPV)

    End Sub

End Module