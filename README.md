
## What are the steps to build an extension

An Extension adds new capabilities to Azure DevOps environment. These capabilities are termed as **_Contributions_**. A Contribution can be of type ```hub```, ```action```, ```build-task``` which is a unit of work or a building block that makes a pipeline. 

To build an extension with one or more tasks:
Using simple ARM deployment, lets build an Azure DevOps Extension in 5 steps.

**_Step 1_**: PowerShell script with Azure Modules invoking ARM template

**_Step 2_**: Download To wrap the scripts as an extension, download the dependent modules (more like SDKs) from [Azure DevOps GitHub](https://github.com/microsoft/azure-pipelines-tasks/tree/master/Tasks/Common), Save it to folder ```ps_modules```. (Yes the name should be exactly that!!)
    * VstsTaskSDK
    * VstsAzureRestHelper
    * VstsAzureHelper
    * TlsHelper (Common library handling security)

**_Step 3_**: Create entry point by adding Invoke script - ```main.ps1```. User input is captured using ```Get-VstsInput```, a parameter object is created to fulfil the ARM template requirements. 

*In case RestAPI is used instead of ARM templates, POST operation payload can also be gathered as input.*

**_Step 4_**: Make this as task. Task acts an interface to collect required information (Parameters).. consider it as a UI. Add ```task.json```. 

```task.json main.ps1``` bridges across user and the script that were created in first step. 

**_Step 5_**: Wrap every thing into an Extension - ```vss-extension.json```
    * Take ownership by assigning it to an Organization
    * Embed tasks
    * Beautify it with icon

## Test your extension - Locally

**_Step 1_**: Import required Azure Modules ```Import-Module Az```

**_Step 2_**: Import VstsSdk Module ```Import-Module .\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1 -Global```

**_Step 3_**: Get Azure context ```Login-AzAccoount``` 

**_Step 4_**: Execute entry point script ```main.ps1```. During execution, each input will be prompted in the attached terminal.

*Note - Since Azure Context is already provided at Step 3, Ignore the values for ```ConnectedServiceNameSelector```, ```ConnectedServiceName```, ```Service Endpoint Url``` can be left empty. Safely ignore the pop out log errors* 
```
##vso[task.logissue type=error]Required: '' service endpoint URL
##vso[task.logissue type=error]Cannot bind argument to parameter 'Endpoint' because it is null.
```

**_Step 5_**: Login to Azure and validate deployed resource if it meets the required controls

## Package and Publish - Locally

TFS cli (tfx) is offered as an npm package. To perform actions locally, nodejs installation is a requirement.

**_Package_**: Navigate to the extension directory. 

```tfx extension create --manifests vss-extension.json```

**_Publish_**: 

```tfx extension create --manifests vss-extension.json```
