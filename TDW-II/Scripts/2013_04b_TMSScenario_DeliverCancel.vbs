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
    Inherits TestToolTDW

    Public Sub New()
        MyBase.New(DVTKActor.TMS, TDW_Scenario.DeliveryCancel)
    End Sub

    Public Overrides Function GetScenarioToRun() As Scenario
        Return New TMSDeliverCancelScenario()
    End Function

End Class

'Implementation of the main function of DVTk scripts
Module DvtkScript

    ' Entry point of this Visual Basic Script.
    Sub Main(ByVal CmdArgs() As String)

        TesttoolRunner.RunTool(New TestTool(), TesttoolRunner.TestSessionFileName_TDW)

    End Sub

End Module