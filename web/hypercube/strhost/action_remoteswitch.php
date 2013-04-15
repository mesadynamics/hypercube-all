<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$url = sprintf("remoteindex.php?%s&widget_id=%s", $template, $_REQUEST['widget_id']);
redirect($url);

?>
