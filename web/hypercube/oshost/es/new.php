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
<h2>Añadir Widget</h2>

<div id='tabs1'><ul>
EndHereDoc;

echo $html;
	
echo "<li id='current'><a href='#'><span>Crear Widget a partir de Código</span></a></li>";
echo sprintf("<li><a href='providers.php?%s'><span>Galería de Proveedores</span></a></li>", $template);
echo sprintf("<li><a href='featured.php?%s'><span>Widget Principales</span></a></li>", $template);
   
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
<td id='tabler'>Nombre:</td>
<td>
<input type='text' maxlength='64' size='45' name='title' value='' />
</td>
</tr>
<tr>
<td id='tabler' style='height:20px'>Código:</td>
<td>
<textarea rows='4' cols='45' name='code' value=''></textarea>
</td>
</tr>
</table>
</div>

<div id='create'><a href='javascript: submitform()'>crear widget</a>
</div>
EndHereDoc3;

echo $html3;

echo sprintf("<div id='cancel'>o <a href='index.php?%s'><span>cancelar</span></a></div>", $template);

$html4 = <<<EndHereDoc4
<div id='message2'>
	<h1>¿Buscando el código del widget?</h1>
Podrá encontrar el código del widget visualizando los “sites” en nuestra Galería de Proveedores o en cualquier lugar que publique widgets, juegos en flash o video que pueda ser incrustado en una página Web. También puede comprobar nuestros “Widgets Principales”, donde se enlaza con una página en la que podrá hallar este código.
     	<br /><br />
Cuando esté listo, teclee un nombre que sea descriptivo y después copie y pegue el código en la caja de arriba. Cuando teclee después en Crear Widget, su nuevo widget aparecerá en una nueva pestaña dentro de Hypercube.</div>

</body>
</html>
EndHereDoc4;

echo $html4;

?>
