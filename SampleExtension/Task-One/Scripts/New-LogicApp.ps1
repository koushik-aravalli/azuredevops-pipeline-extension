[CmdletBinding(DefaultParameterSetName='New')]

Param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the ResourceGroup to host LogicApp", ParameterSetName = 'New')]
    [string]
    $ResourceGroupName,

    [Parameter (Mandatory = $true, HelpMessage = "Path of the LogicApp Template")]
    [string]
    [ValidateScript({Test-Path $_ })]
    $TemplateFilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'New')]
    [string]
    [ValidateScript( {
            if ([string]::IsNullOrEmpty($_) -or ($_ -match '^[a-z0-9]{3,40}')) {
                $true
            }
            else {
                $false
            }
        })]
    $WorkFlowName,

    [Parameter (Mandatory = $false, HelpMessage = "Path of the LogicApp Definition")]
    [string]
    [ValidateScript({
        if ([string]::IsNullOrEmpty($_) -or (Test-Path $_)) {
            $true
        }
        else {
            $false
        }
    })]
    $WorkFlowDefinitionFilePath,

    [Parameter (Mandatory = $false, HelpMessage = "Path of the LogicApp Parameters")]
    [string]
    [ValidateScript({
        if ([string]::IsNullOrEmpty($_) -or (Test-Path $_)) {
            $true
        }
        else {
            $false
        }
    })]
    $WorkFlowParametersFilePath
)

Write-Host "INFO --- Start script at $(Get-Date -Format "dd-MM-yyyy HH:mm")"

$ErrorActionPreference = 'Stop'

$laName=''
$rg = Get-AzResourceGroup -ResourceGroupName $ResourceGroupName

$laName = $ResourceGroupName+"-"+$workFlowName
Write-Output "INFO --- LogicApp to be created with name : $laName" 

#
# Return exception if LogicApp already exists with a non-empty definition
#
try{
    $la = Get-AzLogicApp -ResourceGroupName $rg.ResourceGroupName -Name $laName -ErrorAction SilentlyContinue
    if($la -and $la.Definition -and $la.Definition.actions){
        Write-Error -Message "ERROR --- LogicApp with same name exists with non-empty definition. Rerun LogicApp workflow definition to update."
    }
}
catch{
    $exception = $_.Exception.Message
    Write-Error -Message "ERROR --- : $exception"
}

#
# Deploy LogicApp Shell 
#
Write-Output "INFO --- Start LogicApp deployment."

$outputValue = New-AzResourceGroupDeployment `
    -Name "$laName-$(Get-Date -Format "ddMMyyyyHHmm")" `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile $TemplateFilePath `
    -TemplateParameterObject @{
                                logicAppName = "$laName-suffix"
                            }

$laResourceId = $outputValue.Outputs.Item("logicappId").Value
$laMsi = $outputValue.Outputs.Item("msi").Value

if ($null -eq $outputValue -or [string]::IsNullOrEmpty($laResourceId) -or [string]::IsNullOrEmpty($laMsi)) {
    Write-Error "ERROR --- LogicApp deployment is failed";    
    Return;
}

Write-Output "INFO --- End LogicApp deployment."