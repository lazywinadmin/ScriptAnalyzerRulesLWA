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

                            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                                Message = "Missing parameter '-$CurrentParameter' on command '$CurrentCommand'"
                                Extent  = $CurrentCommand.Extent
                                Rulename = $PSCmdlet.MyInvocation.MyCommand.Name
                                Severity = 'Warning'
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