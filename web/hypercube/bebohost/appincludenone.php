<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2008 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'bebo.php';
//require_once 'php4compat.php';

$appapikey = 'jSbm0tS7IKe7hKEovRI5pIe08f4gHnQJuTpY';
$appsecret = 'nP6Bu3TfafIesXcQxoNvNNBVDQxbZaIzEZby';
$bebo = new Bebo($appapikey, $appsecret);
$user = $bebo->require_login();

//[todo: change the following url to your callback url]
$appcallbackurl = 'http://www.amnestywidgets.com/hypercube/bebohost/';  

function redirect($url) {
	global $bebo;
	
	if(substr($url, 0, 7) == 'http://')
		$bebo->redirect($url);
	else
		$bebo->redirect('http://apps.bebo.com/hypercube/' . $url);
}

?>
