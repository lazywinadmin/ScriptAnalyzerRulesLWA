[![Build Status](https://dev.azure.com/lazywinadmin/ScriptAnalyzerRulesLWA/_apis/build/status/lazywinadmin.ScriptAnalyzerRulesLWA?branchName=master)](https://dev.azure.com/lazywinadmin/ScriptAnalyzerRulesLWA/_build/latest?definitionId=24&branchName=master)

# ScriptAnalyzerRulesLWA

Opinionated PSScriptAnalyzer custom rules

## Getting Started

Install from the PowerShell Gallery

``` powershell
import-module -name ScriptAnalyzerRulesLWA
```

Run the rules against your code

```powershell
Invoke-ScriptAnalyzer -CustomRulePath (Get-Module -name ScriptAnalyzerRulesLWA).path -Path ./MyScript.ps1 -verbose
```

## Contributions

See [Contributing](CONTRIBUTING.md) file.
