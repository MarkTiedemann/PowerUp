
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

function ~~> ($in) 
{
    $in[0]
}

function === ($value)
{
    (~~> $input[0]) -eq $value
}

function ==! ($value)
{
    (~~> $input) -ne $value
}

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
