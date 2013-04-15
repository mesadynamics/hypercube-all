<?php

require_once 'PHPUnit.php';
require_once 'IsterXmlExpatDumper.php';

class TestXml03IsterXmlExpatDumper extends PHPUnit_TestCase
{

  function setUp()
  {
    $this->expat    = new IsterXmlExpatDumper(true);
    $this->string   = '<?xml version="1.0"?><root><node attr="val"></node></root>';
  }

  function tearDown()
  {
  }


  function testParse()
  {
    $this->expat->setSourceString($this->string);
    ob_start();
    $this->expat->parse();
    $result = preg_replace('/\s/', '', ob_get_contents());
    ob_end_clean();
    $expected = 'default_data:<?xml.version="1.0"?>tag_open:roottag_open:nodeattr:attr=valtag_close:nodetag_close:root';
    $this->assertFalse( strcmp($expected, $result) );
  }

}

?>