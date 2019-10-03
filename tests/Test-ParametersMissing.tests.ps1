$here = Split-Path -Parent $MyInvocation.MyCommand.Path # Pester Script folder
$TestDataFolder = Join-Path -Path $here -ChildPath 'testdata'
$ProjectRoot = Split-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".tests.", ".")

# Dot source function
. $(Join-Path $ProjectRoot "\src\public\$sut")

# Import PSScriptAnalyzer module to get the dependent classes/libraries
Import-Module -Name PSScriptAnalyzer

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

Describe "Test-ParametersMissing" {

    Context "Behavior" {

        $ExpectedResult = @{Message  = "Missing named parameter '-0' on the following command 'Select-Property Name'";
                            RuleName = 'Test-ParametersMissing';
                            Severity = 'Warning'}

        $result = Test-ParametersMissing -ScriptBlockAst (Get-ScriptBlockAst -Path (Join-Path -Path $TestDataFolder -ChildPath '1.ps1'))

        It 'Test rule generate output' {
            $result -ne $null | should be $true
        }

        It 'Test output type' {
            $result | Should -BeOfType [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]
        }


        $ExpectedResult.Keys | ForEach-Object -Process {
            It "Output: Testing if '$($_)' is '$($ExpectedResult[$_])'" {
                $result.$_ | Should be $ExpectedResult[$_]
            }
        }

    }
}