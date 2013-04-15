<?php

require_once 'PHPUnit.php';
require_once 'IsterXmlSimpleXMLImpl.php';

class TestXml06IsterXmlSimpleXMLImpl extends PHPUnit_TestCase
{

  function setUp()
  {
    $this->simple = new IsterXmlSimpleXMLImpl;
  }

  function tearDown()
  {
  }


  function testLoad_file()
  {
    $doc = $this->simple->load_file('simple.xml');
    $result   = $doc->movies->movie[1]->title->hasChildren();
    $expected = 1;
    $this->assertTrue( $expected === $result );
  }

  function testLoad_string()
  {
    $xml = '<?xml version="1.0"?><root><node>1</node><node>2</node></root>';
    $doc = $this->simple->load_string($xml);
    $result   = $doc->root->node[1]->CDATA();
    $expected = '2';
    $this->assertFalse( (boolean) strcmp($expected, $result) );
  }
  
  function testSetCDATA1()
  {
    $xml = '<?xml version="1.0"?><root><node>1</node></root>';
    $doc = $this->simple->load_string($xml);
	$doc->root->node->setCDATA('3');
    $result   = $doc->asXML();
    $expected = '<?xml version="1.0"?><root><node>3</node></root>';
    $this->assertFalse( (boolean) strcmp($expected, $result) );
  }
  
  function testSetCDATA2()
  {
    $xml = '<?xml version="1.0"?><root><node>1</node><node>1</node></root>';
    $doc = $this->simple->load_string($xml);
	$doc->root->node[1]->setCDATA('3');
    $result   = $doc->asXML();
    $expected = '<?xml version="1.0"?><root><node>1</node><node>3</node></root>';
    $this->assertFalse( (boolean) strcmp($expected, $result) );
  }
  
  
  function testSetAttribute1()
  {
    $xml = '<?xml version="1.0"?><root><node a="1">2</node></root>';
    $doc = $this->simple->load_string($xml);
	$doc->root->node->setAttribute('a', 2);
    $result   = $doc->asXML();
    $expected = '<?xml version="1.0"?><root><node a="2">2</node></root>';
    $this->assertFalse( (boolean) strcmp($expected, $result) );
  }
  
  function testSetAttribute2()
  {
    $xml = '<?xml version="1.0"?><root><node>1</node><node a="1">2</node></root>';
    $doc = $this->simple->load_string($xml);
	$doc->root->node[1]->setAttribute('a', 2);
    $result   = $doc->asXML();
    $expected = '<?xml version="1.0"?><root><node>1</node><node a="2">2</node></root>';
    $this->assertFalse( (boolean) strcmp($expected, $result) );
  }

  //not implemented
  // function testimport_dom()
  // {
    // $dom = new IsterObject; //should be DOM
    // $result   = get_class($this->simple->import_dom($dom));
    // $expected = 'istersimplexmlelement';
    // $this->assertFalse( strcmp($expected, $result) );
  // }

}


?>