<?php

// $Id: IsterUtilTestAttributeSet.php,v 1.4 2005/02/14 17:03:55 ingo Exp $

require_once 'PHPUnit.php';
require_once 'IsterXmlExpat.php';
require_once 'IsterXmlExpatDumper.php';

class TestXml02IsterXmlExpat extends PHPUnit_TestCase
{

  function setUp()
  {
    $this->expat  = new IsterXmlExpatDumper(false);
    $this->file   = 'simple.xml';
    $this->string = '<?xml version="1.0"?><root><node attr="val"></node></root>';
    $this->error  = '<?xml version="1.0"?><root><node attr="val"></node></root';
  }

  function tearDown()
  {
  }

  function testSetSourceFile()
  {
    $result   = $this->expat->setSourceFile($this->file);
    $expected = true;
    $this->assertTrue($expected === $result);
  }

  function testSetSourceString()
  {
    $result   = $this->expat->setSourceString($this->string);
    $expected = true;
    $this->assertTrue($expected === $result);
  }


  function testParseFile()
  {
    $this->expat->setSourceFile($this->file);
    $result   = $this->expat->parse();
    $expected = true;
    $this->assertTrue($expected === $result);
  }


  function testParseString()
  {
    $this->expat->setSourceString($this->string);
    $result   = $this->expat->parse();
    $expected = true;
    $this->assertTrue($expected === $result);
  }


  function testLocate()
  {
    $this->expat->setSourceString($this->error);
    ob_start();
    $this->expat->parse();
    ob_end_clean();
    $loc = $this->expat->locate();
    $result = implode('', $loc);
    $expected = '51511';
    $this->assertFalse( strcmp($result,$expected));
  }

  function testGetSetParser()
  {
    $this->expat->setSourceString($this->error);
    $parser   = $this->expat->getParser();
    $newexpat = new IsterXmlExpatDumper(false);
    $newexpat->setSourceString($this->error);
    $newexpat->setParser($parser);
    ob_start();
    $newexpat->parse();
    ob_end_clean();
    $loc      = $this->expat->locate();
    $result   = implode('', $loc);
    $expected = '51511';
    $this->assertFalse( strcmp($result,$expected));
  }



}

?>