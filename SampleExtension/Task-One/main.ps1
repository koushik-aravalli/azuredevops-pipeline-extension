# This script creates or removes an Azure LogicApp Service

Trace-VstsEnteringInvocation $MyInvocation

Write-Output "INFO --- Start Azure LogicApp task."

Write-Output "INFO --- Install Az Module."

Import-Module -Name 'Az'

#Install-Module -Name 'Az' -Force -Verbose -Scope CurrentUser -AllowClobber

Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_

# Initialize Azure connection
Initialize-Azure -Strict

# Read inputs values
$resourceGroup              = Get-VstsInput -Name resourceGroupName
$workflowName               = Get-VstsInput -Name workflowName
$WorkFlowDefinitionFilePath = Get-VstsInput -Name WorkFlowDefinitionFilePath
$WorkFlowParametersFilePath = Get-VstsInput -Name WorkFlowParametersFilePath

Write-Output "INFO --- User variables are:"
Write-Output "INFO --- workflowName                 = $workflowName"
Write-Output "INFO --- WorkFlowDefinitionFilePath   = $WorkFlowDefinitionFilePath"
Write-Output "INFO --- WorkFlowParametersFilePath   = $WorkFlowParametersFilePath"

$templatePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'Templates\logicApp.template.json'))

# Invoke Script
Write-Output "INFO --- Creating an Azure LogicApp Service in a Resource Group."
$scriptFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'Scripts\New-LogicApp.ps1'))
. $scriptFile `
    -ResourceGroupName $resourceGroup `
    -WorkFlowName $workflowName `
    -WorkFlowDefinitionFilePath $WorkFlowDefinitionFilePath `
    -WorkFlowParametersFilePath $WorkFlowParametersFilePath `
    -TemplateFilePath $templatePath

Write-Output "INFO --- End Azure LogicApp task."