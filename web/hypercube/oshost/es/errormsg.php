<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (!isset($user)) {
	exit;
}

$html = <<<EndHereDoc
<html>
<head>
	<meta http-equiv='content-type' content='text/html; charset=utf-8'>
	<style type='text/css'>
		@import 'main.css';
	</style>
</head>

<body>
<div id='error'>
EndHereDoc;

echo $html;

switch($_REQUEST['errmsg']) {
	case 0:
		$errmsg = "Por favor, entre un nombre único para este Widget.";
		break;
		
	case 1:
		$errmsg = "Por favor, rellene los campos de Nombre y de Código.";
		break;
}

echo sprintf("<h1>%s</h1>%s",
	$_REQUEST['errtitle'], $errmsg);

echo "</div></body></html>";

?>
