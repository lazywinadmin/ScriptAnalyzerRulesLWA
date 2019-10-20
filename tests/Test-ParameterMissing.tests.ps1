$here = Split-Path -Parent $MyInvocation.MyCommand.Path # Pester Script folder
$TestDataFolder = Join-Path -Path $here -ChildPath 'testdata'
$ProjectRoot = Split-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".tests.", ".")

# Dot source function
. $(Join-Path -path $ProjectRoot -ChildPath "\src\public\$sut")

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

Describe "Test-ParameterMissing" {

    Context "Behavior" {

        It 'Loaded' {
            Get-ChildItem function:/Test-ParameterMissing | should be $true
        }

        $ExpectedResult = @{Message  = "Missing parameter '-Property' on command 'Select-Object Name'";
                            RuleName = 'Test-ParameterMissing';
                            Severity = 'Warning'}

        $result = Test-ParameterMissing -ScriptBlockAst (Get-ScriptBlockAst -Path (Join-Path -Path $TestDataFolder -ChildPath '01-parametermissing.ps1'))

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