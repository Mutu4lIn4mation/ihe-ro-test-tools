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
    Inherits TestToolIPDW_UPS

    Public Sub New()
        MyBase.New(DVTKActor.TMS, UPS_Scenario.UpsFinalUpdate)
    End Sub

    Public Overrides Function GetScenarioToRun() As Scenario
        Return New SendUPSFinalUpdate()
    End Function

End Class

'Implementation of the main function of DVTk scripts
Module DvtkScript

    ' Entry point of this Visual Basic Script.
    <STAThread()> _
    Sub Main(ByVal CmdArgs() As String)

        TesttoolRunner.RunTool(New TestTool(), TesttoolRunner.TestSessionFileName_IPDW_UPS_PDS)

    End Sub

End Module