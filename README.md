
# PowerUp

**PowerShell language utilities.**

## Installation

```powershell
Curl 'https://raw.githubusercontent.com/MarkTiedemann/PowerUp/master/PowerUp.ps1' -OutFile "$pwd\PowerUp.ps1"
```

## Features

### 1 - Inline if function

```powershell

# PowerShell doesn't have an inline if function
# or a ternary operator, so let's fix that

function iif ($condition, $ifTrue, $ifFalse)
{
    if ($condition) {
        if ($ifTrue -is 'ScriptBlock') { &$ifTrue } else { $ifTrue }
    } else {
        if ($ifFalse -is 'ScriptBlock') { &$ifFalse } else { $ifFalse }
    }
}

```

### 2 - Safer comparison operators

```powershell

# The built-in PowerShell comparison operators don't handle function
# calls implicitly which may lead to bugs that are hard to track down

function Get-One { 1 }

Get-One -eq 1  # => 1 - Bug!
Get-One -eq 2  # => 1 - Bug!

# In the above, '-eq 1' is interpreted as a parameter for the Get-One
# function and, since the function doesn't handle the -eq parameter,
# silently omitted

# To get the correct results, you have to use brackets to indicate
# that the -eq operator is not a parameter of the Get-One function,
# but should be applied to its result

(Get-One) -eq 1  # => True
(Get-One) -eq 2  # => False

# To prevent such bugs from occuring in your code base, you could
# use custom pipe comparison operators such as the following

function === { iif ($input[0] -eq $args[0]) $true $false }
function ==! { iif ($input[0] -ne $args[0]) $true $false }

Get-One | === 1  # => True
Get-One | === 2  # => False

Get-One | ==! 1  # => False
Get-One | ==! 2  # => True

```

### 3- Better dot notation

```powershell

# PowerShell does not come with a built-in way to access deeply
# nested object properties and array items with pipes. Instead,
# you have to enclose the entire previous pipe in brackets before
# you can use dot notation to access those items and properties.
# This makes the code both harder to write (since you have to go
# back to the beginning of the pipe) and harder to read (since
# whoever reads the code, will have to go back, too)

$url = 'https://api.github.com/repos/PowerShell/PowerShell/releases'

(Invoke-WebRequest $url | ConvertFrom-Json)[0].tag_name  # => v6.0.0-alpha.10

# So let's fix this with the following function

function .. ($notation)
{
    $obj = $input[0]
    $notation.split('.') | % {
        $split = $_.split('[]')
        # get array item
        if ($_.startsWith('[') -and $_.endsWith(']')) { $obj = $obj.item($split[1]) }
        # get object property, then array item
        if ($_ -match '.+\[[0-9]+\]') { $prop = $split[0]; $obj = $obj.$prop[$split[1]] }
        # get object property
        if (!$_.contains('[') -and !$_.contains(']')) { $obj = $obj.$_ }
    }
    $obj
}

# Now you can use dot notation with pipes to simplify the control
# flow of your code as follows

Invoke-WebRequest $url | ConvertFrom-Json | .. [0].tag_name  # => v6.0.0-alpha.10

```

## License

[WTFPL](http://www.wtfpl.net/) – Do What the F*ck You Want to Public License.

Made with :heart: by [@MarkTiedemann](https://twitter.com/MarkTiedemannDE).
