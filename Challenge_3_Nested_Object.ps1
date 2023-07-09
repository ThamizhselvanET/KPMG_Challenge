function Get-NestedObjectValue 
{ 
param ( 
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()] $Object, 
        
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()] 
        $Key 
    ) 

    $keys = $Key -split '\.' 

    $value = $Object 

    foreach ($k in $keys) { 
        if ($value -is [System.Collections.IDictionary]) 
        { 
            $value = $value[$k] 
        } 
        elseif ($value -is [System.Collections.IEnumerable] -and $k -match '^\d+$') 
        { 
            $value = $value[$k] 
        } 
        else 
        { 
            $value = $value.$k 
        } 
        if ($value -eq $null) 
        { 
            break 
        } 
    } 
    return $value 
} 


$nestedObject = @{ 
    Name = "Vicky" 
    Age = 35 
    Address = @{ 
        Street = "1675 1st Main Road" 
        City = "Chennai" 
        Country = "India" 
    } 
    Pets = @( 
    @{ 
        Name = "Jhonny" 
        Type = "Cow" 
    }, 
    @{ 
        Name = "Jimmy" 
        Type = "Dog" 
    } 
    ) 
} 
$value = Get-NestedObjectValue -Object $nestedObject -Key "Name" 
Write-Host "Name: $value" 
$value = Get-NestedObjectValue -Object $nestedObject -Key "Address.City" 
Write-Host "City: $value" 
$value = Get-NestedObjectValue -Object $nestedObject -Key "Pets.1.Name" 
Write-Host "Second pet's name: $value" 
