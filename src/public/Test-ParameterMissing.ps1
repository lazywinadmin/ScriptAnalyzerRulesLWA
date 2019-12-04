function Test-ParameterMissing
{
<#
.SYNOPSIS
Rule to detect absent or incomplete command parameters

.DESCRIPTION
Rule to detect absent or incomplete command parameters

.PARAMETER ScriptBlockAst
Pass the current scriptblock to the function

.EXAMPLE
This code is usually consumed directly with the module

.LINK
https://github.com/lazywinadmin/ScriptAnalyzerRulesLWA

.NOTES
General notes
#>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    PARAM(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
        )
    begin{
        $FunctionName = $MyInvocation.InvocationName
        Write-Verbose -Message "[$FunctionName] starting..."
    }
    process {
        try{
            # Only look at current block
            if($ScriptBlockAst[0].Extent.text[0] -eq '{'){
                return
            }

            #Find all the object of type CommandAst
            $CommandAst = $ScriptBlockAst.FindAll( {$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)

            Foreach ($CurrentCommand in $CommandAst){

                # Skip Dot Sourcing commands, '&' call operator commands''
                if ($CurrentCommand -notmatch '^\..+ps1|^\..+psm1|^&|^\.'){

                    # Retrieve the parameters
                    $Parameters = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($CurrentCommand)

                    # For each parameters
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
                            ##[string]$correction = "-$CurrentParameter"
                            ##$correctionExtent = New-Object -TypeName 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' -ArgumentList $startLineNumber,$endLineNumber,$startColumnNumber,$correction,'description'
                            #$correctionExtent = New-Object -TypeName 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' -ArgumentList $startLineNumber,$endLineNumber,$startColumnNumber,$endColumnNumber,$correction,'description'

                            ##$suggestedCorrections = New-Object -TypeName System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                            ##$suggestedCorrections.add($correctionExtent) | Out-Null

                            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                                Message = "Missing parameter '-$CurrentParameter' on command '$CurrentCommand' $startLineNumber,$endLineNumber,$startColumnNumber,$endColumnNumber"
                                Extent  = $CurrentCommand.Extent
                                Rulename = $PSCmdlet.MyInvocation.MyCommand.Name
                                Severity = 'Warning'
                                ##SuggestedCorrections = $suggestedCorrections
                            }
                        }
                    }
                }
            }
        }catch{
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}