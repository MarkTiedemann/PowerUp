
. .\PowerUp.ps1

function Test ($desc, $actual, $expected) 
{
    Write-Host ($desc + ': ') -NoNewline
    $a = &$actual
    $e = $expected
    if ($a -eq $e) { Write-Host 'success' -ForegroundColor green }
    else { Write-Host "fail ($e !== $a )" -ForegroundColor red }
}

# Test iff

Test 'if? ($true) 0 : 1 returns 0' { if? ($true) 0 : 1 } 0
Test 'if? ($true) 1 : 0 returns 1' { if? ($true) 1 : 0 } 1
Test 'if? ($false) 0 : 1 returns 1' { if? ($false) 0 : 1 } 1
Test 'if? ($false) 1 : 0 returns 0' { if? ($false) 1 : 0 } 0

Test 'if? ($true) { 0 } : 1 returns 0' { if? ($true) { 0 } : 1 } 0
Test 'if? ($true) { 1 } : 0 returns 1' { if? ($true) { 1 } : 0 } 1
Test 'if? ($false) { 0 } : 1 returns 1' { if? ($false) { 0 } : 1 } 1
Test 'if? ($false) { 1 } : 0 returns 0' { if? ($false) { 1 } : 0 } 0

Test 'if? ($true) 0 : { 1 } returns 0' { if? ($true) 0 : { 1 } } 0
Test 'if? ($true) 1 : { 0 } returns 1' { if? ($true) 1 : { 0 } } 1
Test 'if? ($false) 0 : { 1 } returns 1' { if? ($false) 0 : { 1 } } 1
Test 'if? ($false) 1 : { 0 } returns 0' { if? ($false) 1 : { 0 } } 0

Test 'if? ($true) { 0 } : { 1 } returns 0' { if? ($true) { 0 } : { 1 } } 0
Test 'if? ($true) { 1 } : { 0 } returns 1' { if? ($true) { 1 } : { 0 } } 1
Test 'if? ($false) { 0 } : { 1 } returns 1' { if? ($false) { 0 } : { 1 } } 1
Test 'if? ($false) { 1 } : { 0 } returns 0' { if? ($false) { 1 } : { 0 } } 0

# Test ~~>

Test '~~> 1' { ~~> 1 } 1
Test '~~> 1, 2' { ~~> 1, 2 } 1

function Peek-Type { (~~> $input).getType().name }
function Meek-Type { $input.moveNext() > $null; $input.current.getType().name }
function Zeek-Type { foreach ($i in $input) { $i.getType().name; break } }

function Poop-Type { $input.getType().name }
function Plop-Type { $input[0].getType().name }

Test '0 | Peek-Type returns Int32' { 0 | Peek-Type } Int32
Test '0 | Meek-Type returns Int32' { 0 | Meek-Type } Int32
Test '0 | Zeek-Type returns Int32' { 0 | Zeek-Type } Int32

Test '0 | Poop-Type returns ArrayListEnumeratorSimple' { 0 | Poop-Type } ArrayListEnumeratorSimple
Test '0 | Plop-Type returns ArrayListEnumeratorSimple' { 0 | Plop-Type } ArrayListEnumeratorSimple

# Test === and ==!

function Zero { 0 }
function One { 1 }

Test '0 | === 0 returns true' { 0 | === 0 } $true
Test '0 | === 1 returns false' { 0 | === 1 } $false
Test '1 | === 0 returns false' { 1 | === 0 } $false
Test '1 | === 1 returns true' { 1 | === 1 } $true

Test 'Zero | === 0 returns true' { Zero | === 0 } $true
Test 'Zero | === 1 returns false' { Zero | === 1 } $false
Test 'One | === 0 returns false' { One | === 0 } $false
Test 'One | === 1 returns true' { One | === 1 } $true

Test '0 | ==! 0 returns false' { 0 | ==! 0 } $false
Test '0 | ==! 1 returns true' { 0 | ==! 1 } $true
Test '1 | ==! 0 returns true' { 1 | ==! 0 } $true
Test '1 | ==! 1 returns false' { 1 | ==! 1 } $false

Test 'Zero | ==! 0 returns false' { Zero | ==! 0 } $false
Test 'Zero | ==! 1 returns true' { Zero | ==! 1 } $true
Test 'One | ==! 0 returns true' { One | ==! 0 } $true
Test 'One | ==! 1 returns false' { One | ==! 1 } $false

# Test ...

Test '[ 1 ] | ... [0] returns 1' { '[ 1 ]' | ConvertFrom-Json | ... [0] } 1
Test '{ a: 1 } | ... a returns 1' { '{ "a": 1 }' | ConvertFrom-Json | ... a } 1
Test '{ a: [ 1 ] } | ... a[0] returns 1' { '{ "a": [ 1 ] }' | ConvertFrom-Json | ... a[0] } 1

Test '[{ a: 1 }] | ... [0].a returns 1' { '[{ "a": 1 }]' | ConvertFrom-Json | ... [0].a } 1
Test '{ a: { b: 1 } } | ... a.b returns 1' { '{ "a": { "b": 1 } }' | ConvertFrom-Json | ... a.b } 1
Test '{ a: [{ b: 1 }] } | ... a[0].b returns 1' { '{ "a": [{ "b": 1 }] }' | ConvertFrom-Json | ... a[0].b } 1

Test '[[ 1 ]] | ... [0].[0] returns 1' { '[[ 1 ]]' | ConvertFrom-Json | ... [0].[0] } 1
Test '{ a: [ 1 ] } | ... a.[0] returns 1' { '{ "a": [ 1 ] }' | ConvertFrom-Json | ... a.[0] } 1
Test '{ a: [[ 1 ]] } | ... a[0].[0] returns 1' { '{ "a": [[ 1 ]] }' | ConvertFrom-Json | ... a[0].[0] } 1

Test '[{ a: [ 1 ] }] | ... [0].a[0] returns 1' { '[{ "a": [ 1 ] }]' | ConvertFrom-Json | ... [0].a[0] } 1
Test '{ a: { a: [ 1 ] } } | ... a.a[0] returns 1' { '{ "a": { "a": [ 1 ] } }' | ConvertFrom-Json | ... a.a[0] } 1
Test '{ a: [{ a: [ 1 ] }] } | ... a[0].a[0] returns 1' { '{ "a": [{ "a": [ 1 ] }] }' | ConvertFrom-Json | ... a[0].a[0] } 1