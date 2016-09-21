
function iif ($condition, $ifTrue, $ifFalse)
{
    if ($condition) {
        if ($ifTrue -is 'ScriptBlock') { &$ifTrue } else { $ifTrue }
    } else {
        if ($ifFalse -is 'ScriptBlock') { &$ifFalse } else { $ifFalse }
    }
}

function === ($value)
{
    foreach ($v in $input) { $v -eq $value; break }
}

function ==! ($value)
{
    foreach ($v in $input) { $v -ne $value; break }
}

function .. ($notation)
{
    $obj = $input[0]
    $notation.split('.') | % {
        $split = $_.split('[]')
        # get array item
        if ($_.startsWith('[') -and $_.endsWith(']')) {
            $obj = $obj.item($split[1])
        }
        # get object property, then array item
        if ($_ -match '.+\[[0-9]+\]') {
            $prop = $split[0]
            $obj = $obj.$prop[$split[1]]
        }
        # get object property
        if (!$_.contains('[') -and !$_.contains(']')) {
            $obj = $obj.$_
        }
    }
    $obj
}
