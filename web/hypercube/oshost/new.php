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
<h2>Add Widget</h2>

<div id='tabs1'><ul>
EndHereDoc;

echo $html;
	
echo "<li id='current'><a href='#'><span>Create Widget from Code</span></a></li>";
echo sprintf("<li><a href='providers.php?%s'><span>Provider Gallery</span></a></li>", $template);
echo sprintf("<li><a href='featured.php?%s'><span>Featured Widget</span></a></li>", $template);
   
$html2 = <<<EndHereDoc2
</ul></div>

<form name='form1' action='action.php?create' method='post'>
<script language="JavaScript">
function submitform()
{
	document.form1.submit();
}
</script>
EndHereDoc2;

echo $html2;

echo sprintf("<input type='hidden' name='host' value='%s' />", $host);
echo sprintf("<input type='hidden' name='userid' value='%s' />", $user);
echo sprintf("<input type='hidden' name='userkey' value='%s' />", $userkey);

$html3 = <<<EndHereDoc3
<div id='inputform'>
<table>
<tr>
<td id='tabler'>Name:</td>
<td>
<input type='text' maxlength='64' size='45' name='title' value='' />
</td>
</tr>
<tr>
<td id='tabler' style='height:20px'>Code:</td>
<td>
<textarea rows='4' cols='45' name='code' value=''></textarea>
</td>
</tr>
</table>
</div>

<div id='create'><a href='javascript: submitform()'>create widget</a>
</div>
EndHereDoc3;

echo $html3;

echo sprintf("<div id='cancel'>or <a href='index.php?%s'><span>cancel</span></a></div>", $template);

$html4 = <<<EndHereDoc4
<div id='message2'>
	<h1>Looking for widget code?</h1>
     	You can find widget code browsing the sites in our Provider Gallery or from any site that publishes widgets, 
     	flash games or video that can be embedded on a web page.&nbsp; You can also check out our Featured Widget
     	which includes code to grab and use right away.
     	<br /><br />
     	When you're ready, <b>1) type in your new widget's name,</b> and <b>2) paste
	    the widget code into the box above</b>.&nbsp; When you click <b>create widget</b>, your new widget will appear under a new tab inside Hypercube.
</div>

</body>
</html>
EndHereDoc4;

echo $html4;

?>
