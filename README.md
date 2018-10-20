# PowerUp

**3-character PowerShell language utilities.**

## Installation

```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/MarkTiedemann/PowerUp/master/PowerUp.ps1' -OutFile "$pwd\PowerUp.ps1"
```

## Introduction

**PowerUp helps you safely write PowerShell scripts with less clutter and a better control flow:**

```powershell
if ((Get-NetAdapter Wi-Fi).Status -eq 'Up') { 'w00t' } else { '$#!+' }  # => w00t
```

**vs.**

```powershell
if? (Get-NetAdapter Wi-Fi | ... Status | === Up) 'w00t' : '$#!+'  # => w00t
```

## Features

### `if?` - Inline if function

```powershell
# PowerShell doesn't have an inline if function
# or a ternary operator, so let's fix that

function if? ($condition, $ifTrue, $colon, $ifFalse)
{
    if ($condition)
    {
        if ($ifTrue -is [ScriptBlock]) { &$ifTrue } else { $ifTrue }
    }
    else
    {
        if ($ifFalse -is [ScriptBlock]) { &$ifFalse } else { $ifFalse }
    }
}
```

### `~~>` - Pipe peek

```powershell
# To get the first element from the pipe, i.e. to peek into the pipe,
# in PowerShell you should never directly access the input object, but
# iterate over it

# That is because, as the following functions show, the input object is
# always an ArrayListEnumeratorSimple (even if the input was an Int32)

function Poop-Type { $input.GetType().Name }
1 | Poop-Type  # => ArrayListEnumeratorSimple

function Plop-Type { $input[0].GetType().Name }
1 | Plop-Type  # => ArrayListEnumeratorSimple

# There are multiple solutions for fixing this, e.g.

# 1 - Using the iterators .moveNext() method in combination with its
# .current property
function Meek-Type { $input.moveNext() > $null; $input.current.GetType().Name }
1 | Meek-Type  # => Int32

# 2 - Using the built-in foreach loop and breaking after the first item
function Zeek-Type { foreach ($i in $input) { $i.GetType().Name; break } }
1 | Zeek-Type  # => Int32

# 3 - Using a proxy function (which automatically casts the iterator)
function ~~> ($in) { $in[0] }
function Peek-Type { (~~> $input).GetType().Name }
1 | Peek-Type  # => Int32
```

### `===` & `==!` - Pipe equality operators

```powershell
# The built-in PowerShell equality operators don't handle function
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
# use custom pipe equality operators such as the following

function === ($value)
{
    (~~> $input) -eq $value
}

function ==! ($value)
{
    (~~> $input) -ne $value
}

Get-One | === 1  # => True
Get-One | === 2  # => False

Get-One | ==! 1  # => False
Get-One | ==! 2  # => True

# However, the built-in '-eq' operator does coerce types, so:

Get-One | === '1' # => True
Get-One | ==! '1' # => False

# To fix this, you can further modify the functions as follows:

function === ($value) {
  $in = ~~> $input
  if ($in.GetType() -ne $value.GetType()) {
    $false
  }
  else {
    $in -eq $value
  }
}

function ==! ($value) {
  $in = ~~> $input
  if ($in.GetType() -ne $value.GetType()) {
    $true
  }
  else {
    $in -ne $value
  }
}

# Finally, types are handled properly, too:

Get-One | === '1' # => False
Get-One | ==! '1' # => True
```

### `...` - Pipe dot notation

```powershell
# PowerShell does not come with a built-in way to access deeply
# nested Object properties and Array items with pipes

# Instead, you have to enclose the entire previous pipe in brackets
# before you can use dot notation to access those items and properties

# This makes the code both harder to write (since you have to go
# back to the beginning of the pipe) and harder to read (since
# whoever reads the code, will have to go back, too)

$url = 'https://api.github.com/repos/PowerShell/PowerShell/releases'

(Invoke-WebRequest $url | ConvertFrom-Json)[0].tag_name  # => v6.0.0-alpha.10

# So let's fix this with the following function

function ... ($notation)
{
    $obj = ~~> $input
    $notation.split('.') | % {
        $split = $_.split('[]')
        # get Array item
        if ($_.startsWith('[') -and $_.endsWith(']')) {
            # handle default Array
            if ($obj -is [Array]) {
                $obj = $obj[$split[1]]
            }
            # handle System.Array
            if ($obj -is [System.Array]) {
                $obj = $obj.item($split[1])
            }
        }
        # get Object property, then Array item
        if ($_ -match '.+\[[0-9]+\]') {
            $prop = $split[0]
            $obj = $obj.$prop[$split[1]]
        }
        # get Object property
        if (!$_.contains('[') -and !$_.contains(']')) {
            $obj = $obj.$_
        }
    }
    $obj
}

# Now you can use dot notation with pipes to simplify the control
# flow of your code as follows

Invoke-WebRequest $url | ConvertFrom-Json | ... [0].tag_name  # => v6.0.0-alpha.10
```

## Development

- **Testing**: Run `Test.ps1`
- **Todo**: [Write the manual](https://technet.microsoft.com/en-us/magazine/ff458353.aspx)

## License

MIT
