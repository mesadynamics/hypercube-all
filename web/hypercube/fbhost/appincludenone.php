<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'facebook.php';
//require_once 'php4compat.php';

$appapikey = 'f562d6cca09e4a3b9b54e87dc90a958c';
$appsecret = '3fcc7439544543ed1dbe4eaa5a6d908b';
$facebook = new Facebook($appapikey, $appsecret);

if ($facebook->fb_params['added'])
	$user = $facebook->get_loggedin_user();

//[todo: change the following url to your callback url]
$appcallbackurl = 'http://www.amnestywidgets.com/hypercube/fbhost/';  

?>
