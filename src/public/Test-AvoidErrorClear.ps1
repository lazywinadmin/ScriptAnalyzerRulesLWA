function Test-AvoidErrorClear
{
<#
.SYNOPSIS
Rule to the usage of $error.clear()

.DESCRIPTION
Rule to the usage of $error.clear()

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
    PARAM(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
        )

    process {
        try{
            #Only look at current block
            if($ScriptBlockAst[0].Extent.text[0] -eq '{'){
                return
            }

            [scriptblock]$PredicatePipelineAst = {
                Param(
                    [System.Management.Automation.Language.Ast]$ast
                )
                [bool]$returnvalue=$false

                if ($ast -is [System.Management.Automation.Language.PipelineAst]){
                    $returnvalue = $true
                }
                $returnvalue
            }

            # Get the list of commands
            [System.Management.Automation.Language.Ast[]]$PipelineAstList = $ScriptBlockAst.FindAll($PredicatePipelineAst,$true)

            # Loop through all the commands and find the item
            foreach($Pipeline in $PipelineAstList){
                if ($Pipeline.Extent.Text -match '\$Error\.Clear\(\)'){
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message = 'Avoid using $Error.clear()'
                        Extent = $Pipeline.Extent
                        Rulename = $PSCmdlet.MyInvocation.MyCommand.Name
                        Severity = 'Warning'
                    }
                }
            }
        }catch{
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}