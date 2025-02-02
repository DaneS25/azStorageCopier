# Login using device code authentication
Connect-AzAccount #-Identity (uncomment -Identity to force full login protocol)

# List all subscriptions available
$subscriptions = Get-AzSubscription | Select-Object -ExpandProperty Name

# Function to prompt the user for valid input from a list
function Get-ValidInput {
    param (
        [string[]]$validOptions,
        [string]$prompt
    )
    while ($true) {
        $userInput = Read-Host $prompt
        if ($validOptions -contains $userInput -or $userInput -eq "all") {
            return $userInput
        } else {
            Write-Host "Invalid input. Please select a valid option from the list."
            Write-Host "Valid options: $($validOptions -join ', '), or 'all'"
        }
    }
}

# Prompt user to select source subscription
$sourceSubscription = Get-ValidInput -validOptions $subscriptions -prompt "Select source subscription from the list: $($subscriptions -join ', ')"
$sourceSubscriptionId = (Get-AzSubscription | Where-Object { $_.Name -eq $sourceSubscription }).Id
Set-AzContext -SubscriptionId $sourceSubscriptionId

# List all resource groups in the selected source subscription
$resourceGroups = Get-AzResourceGroup | Select-Object -ExpandProperty ResourceGroupName

# Prompt user to select a source resource group
$sourceResourceGroup = Get-ValidInput -validOptions $resourceGroups -prompt "Select source resource group from the list: $($resourceGroups -join ', ')"

# List all storage accounts in the selected source resource group
$sourceStorageAccounts = Get-AzStorageAccount -ResourceGroupName $sourceResourceGroup | Select-Object -ExpandProperty StorageAccountName

# Prompt user to select a storage account for the source
$sourceStorageAccount = Get-ValidInput -validOptions $sourceStorageAccounts -prompt "Select source storage account from the list: $($sourceStorageAccounts -join ', ')"

# Get source account context using OAuth/Entra ID
$sourceContext = New-AzStorageContext -StorageAccountName $sourceStorageAccount -UseConnectedAccount

# List all containers in the source storage account
$sourceContainers = Get-AzStorageContainer -Context $sourceContext | Select-Object -ExpandProperty Name

# Prompt user to select containers for the source
$sourceContainerSelection = Read-Host "Select source containers from the list (comma-separated, or 'all' to select all): $($sourceContainers -join ', ')"

if ($sourceContainerSelection -eq "all") {
    $sourceContainersToCopy = $sourceContainers
} else {
    $sourceContainersToCopy = $sourceContainerSelection -split ',' | ForEach-Object { $_.Trim() }
}

# Prompt user to select target subscription
$targetSubscription = Get-ValidInput -validOptions $subscriptions -prompt "Select target subscription from the list: $($subscriptions -join ', ')"
$targetSubscriptionId = (Get-AzSubscription | Where-Object { $_.Name -eq $targetSubscription }).Id
Set-AzContext -SubscriptionId $targetSubscriptionId

# List all resource groups in the selected target subscription
$resourceGroups = Get-AzResourceGroup | Select-Object -ExpandProperty ResourceGroupName

# Prompt user to select a target resource group
$targetResourceGroup = Get-ValidInput -validOptions $resourceGroups -prompt "Select target resource group from the list: $($resourceGroups -join ', ')"

# List all storage accounts in the target resource group
$targetStorageAccounts = Get-AzStorageAccount -ResourceGroupName $targetResourceGroup | Select-Object -ExpandProperty StorageAccountName

# Prompt user to select a storage account for the target
$targetStorageAccount = Get-ValidInput -validOptions $targetStorageAccounts -prompt "Select target storage account from the list: $($targetStorageAccounts -join ', ')"

# Get target account context using OAuth/Entra ID
$targetContext = New-AzStorageContext -StorageAccountName $targetStorageAccount -UseConnectedAccount

# Skip destination container selection if multiple containers are selected or 'all' is chosen
if ($sourceContainersToCopy.Count -gt 1 -or $sourceContainerSelection -eq "all") {
    Write-Host "Multiple containers selected. Destination container selection skipped. Containers will be copied with the same names."
} else {
    # List all containers in the target storage account
    $targetContainers = Get-AzStorageContainer -Context $targetContext | Select-Object -ExpandProperty Name

    # Prompt user to select a container for the target, or create a new one
    $targetContainer = Read-Host "Select target container from the list (or press Enter to create a new one): $($targetContainers -join ', ')"

    if (-not $targetContainer) {
        $targetContainer = Read-Host "Enter a name for the new target container"
        Write-Host "Creating new target container: $targetContainer"
        New-AzStorageContainer -Name $targetContainer -Context $targetContext
    } elseif (-not ($targetContainers -contains $targetContainer)) {
        Write-Host "The target container '$targetContainer' does not exist. Creating it now..."
        New-AzStorageContainer -Name $targetContainer -Context $targetContext
    }
}

# Loop through each selected container and copy its contents
foreach ($sourceContainer in $sourceContainersToCopy) {
    # Verify that the source container exists
    if (-not (Get-AzStorageContainer -Name $sourceContainer -Context $sourceContext)) {
        Write-Error "Source container $sourceContainer does not exist."
        continue
    }

    # If multiple containers are selected, use the same name for the target container
    if ($sourceContainersToCopy.Count -gt 1 -or $sourceContainerSelection -eq "all") {
        $targetContainer = $sourceContainer
        if (-not (Get-AzStorageContainer -Name $targetContainer -Context $targetContext)) {
            Write-Host "Creating target container: $targetContainer"
            New-AzStorageContainer -Name $targetContainer -Context $targetContext
        }
    }

    # List all available blobs in the source container
    $blobs = Get-AzStorageBlob -Container $sourceContainer -Context $sourceContext

    # Loop through each blob and copy it to the target
    foreach ($blob in $blobs) {
        Write-Host "Copying blob: $($blob.Name) from container: $sourceContainer to container: $targetContainer"

        # Download the blob content to a temporary file
        $tempFilePath = [System.IO.Path]::GetTempFileName()
        Get-AzStorageBlobContent -Blob $blob.Name -Container $sourceContainer -Context $sourceContext -Destination $tempFilePath -Force

        # Upload the blob content to the target container without metadata
        Set-AzStorageBlobContent -File $tempFilePath -Container $targetContainer -Context $targetContext -Blob $blob.Name -Force

        # Clean up the temporary file
        Remove-Item -Path $tempFilePath -Force

        Write-Host "$($blob.Name) copied successfully to target container: $targetContainer"
    }
}

Write-Host "All selected containers have been copied."