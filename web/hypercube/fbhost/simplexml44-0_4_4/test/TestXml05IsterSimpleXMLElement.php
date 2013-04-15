<?php

require_once 'PHPUnit.php';
require_once 'IsterXmlExpatNonValid.php';

class TestXml05IsterSimpleXMLElement extends PHPUnit_TestCase
{

  function setUp()
  {
    $expat = new IsterXmlExpatNonValid;
    $expat->setSourceFile('simple.xml');
    $expat->parse();
    $doc = $expat->getDocument();
    $this->simple = $doc->toSimpleXML();
  }

  function tearDown()
  {
	  unset($this->simple);
  }


  function testAccessNode()
  {
    $result   = $this->simple->movies->movie[1]->title->hasChildren();
    $expected = 1;
    $this->assertTrue( $expected === $result );
  }
  
  function testChildren1()
  {
    $result   = count($this->simple->movies->movie[0]->characters->children());
    $expected = 2;
    $this->assertTrue( $expected === $result );
  }
  
  function testChildren2()
  {
	$result   = count($this->simple->movies->movie[0]->characters->character[0]->children());
    $expected = 2;
    $this->assertTrue( $expected === $result );
  }
  
  function testChildren3()
  {
	$result   = count($this->simple->movies->movie[1]->children());
    $expected = 1;
    $this->assertTrue( $expected === $result );
  }
  
  function testChildren4()
  {
	$result   = count($this->simple->movies->movie[2]->children());
    $expected = 2;
    $this->assertTrue( $expected === $result );
  }

  function testAccessCDATA()
  {
    $result   = $this->simple->movies->movie[1]->title->CDATA();
    $expected = 'nop';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testAccessAttributes()
  {
    $attr = $this->simple->movies->movie[0]->rating[0]->attributes();
    $result   = $attr['type'];
    $expected = 'thumbs';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testAccessParsedEntity()
  {
    $result   = $this->simple->movies->movie[0]->characters->character[1]->extra->asXML();
    $expected = '<extra/>';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testAccessExternalEntity()
  {
    $result   = $this->simple->movies->movie[2]->title[0]->CDATA();
    $expected = 'external';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testSetCDATA()
  {
    $this->simple->movies->movie[1]->title->setCDATA('foo');
    $cdata    = $this->simple->movies->movie[1]->title->CDATA();
    $xml      = $this->simple->movies->movie[1]->title->asXML();
    $result   = $cdata.$xml;
    $expected = 'foo<title>foo</title>';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testSetAttribute()
  {
    $this->simple->movies->movie[0]->rating[0]->setAttribute('type', 'bar');
    $attr = $this->simple->movies->movie[0]->rating[0]->attributes();
    $xml  = $this->simple->movies->movie[0]->rating[0]->asXML();
    $result   = $attr['type'].$xml;
    $expected = 'bar<rating type="bar">7</rating>';
    $this->assertFalse( strcmp($expected, $result) );
  }
  
}


?>