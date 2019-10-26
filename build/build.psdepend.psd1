@{
    PSDependOptions = @{
        #Target = '.\dependencies'
        AddToPath = $true
        #DependencyType = 'PSGalleryNuget'
    }
    Pester = @{
        Name = 'Pester'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    PowerShellGet = '2.1.3'
    PackageManagement = '1.3.2'
    PSScriptAnalyzer = 'Latest'
    BuildHelpers = 'Latest'
    PSDeploy = 'Latest'
    InvokeBuild = 'Latest'
}