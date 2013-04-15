<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'widgetinclude.php';

$secret = '3fcc7439544543ed1dbe4eaa5a6d908b';
$sig = '';
ksort($_POST);
foreach ($_POST as $key => $val) {
    if ($key == 'fb_sig') {
        continue;
    }

    $sig .= substr($key, 7) . '=' . $val;
}

$sig .= $secret;
$verify = md5($sig);
if ($verify == $_POST['fb_sig']) {
	$query = sprintf("update facebook set fb_sig_time = '%s' where fb_sig_user = %s",
		$_POST['fb_sig_time'], $_POST['fb_sig_user']);
	query($query);

    // Update your database to note that fb_sig_user has removed your application
} else {
    // Log the IP and POST for future reference 
}

?>
