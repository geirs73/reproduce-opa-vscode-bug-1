<#
.SYNOPSIS
Script for fetching opa.exe and regal.exe

#>

param(
    [string] $OpaVersionNumber,
    [string] $RegalVersionNumber,
    [string] $PostFix = ''

)


[string] $PublishDir = $(Join-Path $PSScriptRoot 'bin')

function Main {

    try {
        if (!(Test-Path -PathType Container $PublishDir)) {
            New-Item -ItemType Directory -Path $PublishDir | Out-Null
        }

        Write-Host "Opa Exe Fetch script"
        Write-Host "Powershell version: $($PSVersionTable.PSVersion)"

        if (!$OpaVersionNumber) {
            $OpaVersionNumber = Get-LatestVersionNumberFromGitHub -ReleasesUrl "https://github.com/open-policy-agent/opa/releases"
        }
        if (!$RegalVersionNumber) {
            $RegalVersionNumber = Get-LatestVersionNumberFromGitHub -ReleasesUrl "https://github.com/StyraInc/regal/releases"
        }
        ## Or we could also directly download from opa/releases/latest/download/... but it isn't that much easier.
                
        Write-Host "Downloading opa.exe version v$OpaVersionNumber to directory"
        Invoke-WebRequest -OutFile (Join-Path $PublishDir 'opa.exe') -Uri "https://github.com/open-policy-agent/opa/releases/download/v$OpaVersionNumber/opa_windows_amd64.exe"
        
        Write-Host "Downloading regal.exe version v$OpaVersionNumber to directory"
        Invoke-WebRequest -OutFile (Join-Path $PublishDir 'regal.exe') -Uri "https://github.com/StyraInc/regal/releases/download/v${RegalVersionNumber}/regal_Windows_x86_64.exe"

        Write-Host "Finished"
    }
    catch {
        throw
    }
}

function Get-LatestVersionNumberFromGitHub {
    param (
        [string] $ReleasesUrl
    )

    $releasesUri = New-Object System.Uri -ArgumentList $releasesUrl
    if ($releasesUri.Host -ne "github.com") {
        throw "Not a github.com address"
    }

    # Stop any redirection so that we get the redirect URL to use, also skip creating exception on 30x-response.
    $response = Invoke-WebRequest -Uri "$releasesUrl/latest" -MaximumRedirection 0 -SkipHttpErrorCheck -ErrorAction SilentlyContinue
    $redirectUrl = $response.Headers.Location
    $redirectUri = New-Object System.Uri -ArgumentList $redirectUrl
    $versionString = $redirectUri.Segments[-1]
    $version = $versionString.Substring(1)
    return $version
}

Main