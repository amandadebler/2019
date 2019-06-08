#REQUIRES -Version 5.0
#REQUIRES #-Modules
#REQUIRES #-RunAsAdministrator

function New-Deployment {
    <#
    .SYNOPSIS
    Create the resource

    .DESCRIPTION
    Create the resource

    .EXAMPLE
    C:\PS>New-xAzCosmosDeployment -ResourceName $ResourceName -ResourceGroupName $RGName
    Example of how to use this cmdlet

    .PARAMETER ResourceName
    Resource Name
    Can be generated by using Get-xAzCosmosName

    .PARAMETER ResourceGroupName
    Resource Group Name

    .PARAMETER Location
    Name of Azure Location - e.g. WestEurope
    [ValidateScript( { (Get-AzLocation).Location -contains $_ } )]

    .PARAMETER DeploymentParameter
    Inline parameter to pass to deployment

    .PARAMETER WhatIf
    Dry run of script, returns input values

    .PARAMETER Confirm
    Before impacting system ask to confirm
    #>


    [CmdletBinding(
        SupportsShouldProcess = $True,
        PositionalBinding = $True,
        DefaultParameterSetName = "Default"
    )]

    [OutputType([PSCustomObject])]
    param(
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "Enter name of Resource"
        )]
        [string] $ResourceName,

        [Parameter(
            Mandatory,
            Position = 1,
            HelpMessage = "Enter name of Resource Group"
        )]
        [string] $ResourceGroupName,

        [Parameter(
            Mandatory,
            Position = 2,
            HelpMessage = "Enter name of Azure location - e.g. WestEurope"
        )]
        [ValidateScript( { (Get-AzLocation).Location -contains $_ } )]
        [Alias("Loc")]
        [string] $Location,

        [Parameter(
            HelpMessage = "Inline parameter to pass to deployment"
        )]
        $DeploymentParameter
    )

    begin {
        $TemplateUri = Get-xAzCosmosTemplate
        # Register Providers
    }

    process {
        Write-Verbose ("[$(Get-Date)] ResourceName {0}" -f $ResourceName)

        $ResourceGroup = Get-AzResourceGroup $ResourceGroupName -ErrorAction Stop
        Write-Verbose ("[$(Get-Date)] ResourceGroup {0}" -f $ResourceGroup.ResourceGroupName)

        $TemplateParameterObject = @{
            resourceName = $ResourceName
        }

        try {

            if ($PSCmdlet.ShouldProcess($ResourceGroupName, $ResourceName)) {
                if ( $DeploymentParameter ) {
                    $Deployment = New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri @DeploymentParameter -ErrorVariable ErrorMessages
                }
                else {
                    $Deployment = New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri -TemplateParameterObject $TemplateParameterObject -ErrorVariable ErrorMessages
                }

                $return = Get-DeploymentOutput -Deployment $Deployment -ErrorMessage $ErrorMessages
            }
            else {
                $return = $TemplateParameterObject
            }

            $return
        }
        catch [Exception] {
            Write-Error "$($_.Exception) found"
            Write-Verbose "$($_.ScriptStackTrace)"
            throw $_
        }
    }
    end {
    }
}

# Export-ModuleMember -Function New-xAzCosmosDeployment
# New-xAzCosmosDeployment -ResourceName -ResourceGroupName
