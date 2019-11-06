# Trying to replace or insert a missing parameter
## Helpful: https://www.powershellgallery.com/packages/EditorServicesCommandSuite/0.4.0/Content/Public%5CConvertTo-SplatExpression.ps1
## Show one error for multiple parameter missing ?

function Get-ScriptBlockAst
{
    param(
        [string]
        $Path
    )

    New-Variable -Name Tokens
    New-Variable -Name ParseErrors

    $Ast = [Management.Automation.Language.Parser]::ParseFile($Path, [ref]$Tokens, [ref]$ParseErrors)

    $Ast
}

$ScriptBlockAst =((Get-ScriptBlockAst -path /home/fx/code/ScriptAnalyzerRulesLWA/tests/testdata/01-parametermissing.ps1))
# Retrieve all Ast components
if($ScriptBlockAst[0].Extent.text[0] -eq '{'){
    return
}
$CommandAst=$ScriptBlockAst.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
# Show the typename
#$Cmd|Select *,@{L='Type';E={$_.gettype().fullname}}
Foreach ($CurrentCommand in $CommandAst){

    # Skip Dot Sourcing commands, '&' call operator commands''
    if ($CurrentCommand -notmatch '^\..+ps1|^\..+psm1|^&|^\.'){

        # Retrieve the parameters
        #[System.Management.Automation.Language.StaticParameterBinder]::BindCommand
        '######### CURRENT COMMAND'
        $CurrentCommand.CommandElements


        $Parameters = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($CurrentCommand)
        '########### Parameters'
        $Parameters.boundparameters
        # For each parameters

        <#
        foreach ($CurrentParameter in ($Parameters.boundparameters.keys)){
            if($CurrentCommand.tostring() -notmatch "\s-$CurrentParameter" -and
            $CurrentCommand.tostring() -notmatch ' @' -and
            "-$CurrentParameter" -notmatch '^-([0-9]{1})'){

                # Retrieve lines where the parameter is missing
                [int]$startLineNumber =  $CurrentCommand.Extent.StartLineNumber
                [int]$endLineNumber = $CurrentCommand.Extent.EndLineNumber
                [int]$startColumnNumber = $CurrentCommand.Extent.StartColumnNumber
                [int]$endColumnNumber = $CurrentCommand.Extent.EndColumnNumber

                # Define where the parameter must go
                [string]$correction = '' #$CurrentCommand -replace "" "-$CurrentParameter "
                #$correctionExtent = New-Object -TypeName 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' -ArgumentList $startLineNumber,$endLineNumber,$startColumnNumber,$correction,'description'
                $correctionExtent = New-Object -TypeName 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' -ArgumentList $startLineNumber,$endLineNumber,$startColumnNumber,$endColumnNumber,$correction,'description'

                $suggestedCorrections = New-Object -TypeName System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                $suggestedCorrections.add($correctionExtent) | Out-Null

                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message = "Missing parameter '-$CurrentParameter' on command '$CurrentCommand' $startLineNumber,$endLineNumber,$startColumnNumber,$endColumnNumber"
                    Extent  = $CurrentCommand.Extent
                    Rulename = $PSCmdlet.MyInvocation.MyCommand.Name
                    Severity = 'Warning'
                    SuggestedCorrections = $suggestedCorrections
                }

                "##########Elements"
                $CurrentCommand.CommandElements
                $El = $CurrentCommand.CommandElements
                $el.value -join ' '
            }
        }
        #>
    }
}

# Retrieve child element of the commandsast
#((Get-ScriptBlockAst -path (Resolve-Path ./tests/testdata/01-parametermissing.ps1)).findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)).CommandELements
#((Get-ScriptBlockAst -path (Resolve-Path ./tests/testdata/01-parametermissing.ps1)).findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)).findall({$args[0] -is [System.Management.Automation.Language.StringConstantExpressionAst]},$true)
