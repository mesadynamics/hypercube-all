<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2008 Mesa Dynamics, LLC. All rights reserved.
//

function http_build_query($array)
{
	array_walk($array, create_function('&$val,$key', 'urlencode($key)."=".urlencode($val);'));
	return implode('&', $array);
}

?>
