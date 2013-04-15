<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'facebook.php';
//require_once 'php4compat.php';

$appapikey = 'f562d6cca09e4a3b9b54e87dc90a958c';
$appsecret = '3fcc7439544543ed1dbe4eaa5a6d908b';
$facebook = new Facebook($appapikey, $appsecret);
$user = $facebook->require_login();

//[todo: change the following url to your callback url]
$appcallbackurl = 'http://www.amnestywidgets.com/hypercube/fbhost/';  

//catch the exception that gets thrown if the cookie has an invalid session_key in it
try {
  if (!$facebook->api_client->users_isAppUser()) {
    $facebook->redirect($facebook->get_add_url());
  }
} catch (Exception $ex) {
  //this will clear cookies for your application and redirect them to a login prompt
  $facebook->set_user(null, null);
  $facebook->redirect($appcallbackurl);
}

?>
