<?php

// $Id: unittest.php,v 1.4 2005/01/20 20:19:43 ingo Exp $

ini_set('include_path', './:../class:../../lib:./PEAR');

include_once 'PHPUnit.php';
include_once 'test.setup';

// APD
if( function_exists('apd_set_pprof_trace') ) {
  apd_set_pprof_trace(); }

ini_set("error_reporting", E_ALL);

$testcount  = 0;
$testpassed = 0;
$testfailed = 0;

function print_header($string)
{
  $str  = "\nrunning regression tests on ".$string;
  $str .= "\n".(underline($str))."\n";
  print $str;
}

function underline($str)
{
  $line = '';
  for ( $i = 1; $i < strlen($str); $i++)
    $line .= '-';
  return $line;
}

function versionTest()
{
  global $minversion;
  $version = phpversion();
  $expectstr = "expected at least PHP $minversion";

  print "\n";
  if( version_compare($minversion, $version) > 0 )
    {
      print "WARNING: found PHP $version, $expectstr\n";
    }
  else
    {
      print "OK, found PHP $version, $expectstr\n";
    }
}

versionTest();

$dir = opendir('./');

while( $file = readdir($dir) )
  {
    if (preg_match("/^$prefix/", $file))
      $tests[] = basename( $file, ".php");
  }

if(! count($tests) )
{
  print "Hm, no tests found...\n";
  exit(1);
}

sort($tests);

foreach( $tests as $test )
    {
      include "$test".".php";
      
      print_header($test);

      $suite  = new PHPUnit_TestSuite($test);
      $result = PHPUnit::run($suite);
      $count  = $result->runCount();
      $pass   = count($result->passedTests());
      $fail   = $count - $pass;
      $testcount  += $count;
      $testpassed += $pass;
      $testfailed += $fail;
      print $result->toString();
      
    }

print "\n";
print "Summary\n".(underline('Summary '))."\n";
print "executed $testcount tests: $testpassed passed, $testfailed failed\n\n";

?>
