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
<h2>Incluir Widget</h2>

<div id='tabs1'><ul>
EndHereDoc;

echo $html;
	
echo "<li id='current'><a href='#'><span>Criar Widget a partir do Código</span></a></li>";
echo sprintf("<li><a href='providers.php?%s'><span>Galeria de Provedores</span></a></li>", $template);
echo sprintf("<li><a href='featured.php?%s'><span>Widget em Destaque</span></a></li>", $template);
   
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
<td id='tabler'>Nome:</td>
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

<div id='create'><a href='javascript: submitform()'>criar widget</a>
</div>
EndHereDoc3;

echo $html3;

echo sprintf("<div id='cancel'>ou <a href='index.php?%s'><span>cancelar</span></a></div>", $template);

$html4 = <<<EndHereDoc4
<div id='message2'>
	<h1>Buscando código para widgets?</h1>
     	Você pode encontrar códigos para widgets navegando pelos sites na nossa Galeria de Provedores ou em qualquer site que publique widgets, jogos em flash ou vídeos que possam ser colocados em uma página da web.&nbsp;  Você
		pode também visitar nosso Widget em Destaque, com link para a página com seu código.
     	<br /><br />
     	Quando estiver pronto, digite um nome descritivo e copie e cole o código na caixa acima.&nbsp;  Ao clicar em <b>criar widget</b> seu novo widget aparecerá em uma nova aba no Hypercube.
</div>

</body>
</html>
EndHereDoc4;

echo $html4;

?>
