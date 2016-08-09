<?php

namespace Kaleidoscope\Libraries;

use \Kaleidoscope\Exceptions\ConfigParseException;
use \Kaleidoscope\Exceptions\KaleidoscopeException;
use \Kaleidoscope\Libraries\BNETClient;
use \Kaleidoscope\Libraries\UserAccess;

class Common {

  public static $config     = null;
  public static $configFile = "";
  public static $exitCode   = 0;

  private function __construct() {}

  public static function getPlatformName() {
    return php_uname("srm");
  }

  public static function parseArgs($args) {

    array_shift($args); // Remove application path

    $ubound = count($args);

    if ($ubound % 2 == 1) {
      fwrite(STDERR, "Insufficient number of arguments\n");
      Common::$exitCode = 1;
      return;
    }

    $key = null; $val = null;

    for ($i = 0; $i < $ubound; ++$i) {

      if ($i % 2 == 0) {
        $key = $args[$i];
        continue;
      }

      $val = $args[$i];

      switch ($key) {
        case "/config": case "/c": case "-config": case "-c": case "--config":
          self::$configFile = $val;
          break;
        default:
          fwrite(STDERR, "Invalid argument: " . $key . "\n");
          self::$exitCode = 1;
          return;
      }

    }

  }

  public static function parseConfig() {

    $file = self::$configFile;

    if (empty($file)) {
      $file = getcwd() . "/../etc/kaleidoscope.conf";
      fwrite(STDERR, "Assuming config file: " . $file . "\n");
    }

    if (!file_exists($file)) {
      throw new KaleidoscopeException("Config not found: " . $file);
    }

    if (!is_readable($file)) {
      throw new KaleidoscopeException("Config not readable: " . $file);
    }

    $stream = null;
    $lineId = null; $cursor = null; $depth = null;
    $line = null; $lineStr = null; $groups = null; $group = null; $key = null;
    $val = null;
    $client = null; $access = null;

    try {

      $stream = fopen($file, "r");
      $lineId = 0;
      $depth  = 0;
      $groups = [];

      while (!feof($stream)) {

        $line     = trim(fgets($stream));
        $lineId  += 1;
        $lineStr  = " at line " . $lineId;

        if (strlen($line) == 0) continue;
        if (substr($line, 0, 1) == "#") continue;

        if (substr($line, -1) == "{") {

          $groups[]  = trim(substr($line, 0, strlen($line) - 1));
          $group     = $groups[count($groups) - 1];
          $depth    += 1;

          switch (strtolower($group)) {
            case "": {
              if ($depth > 1) {
                throw new ConfigParseException(
                  "Global scope group being used inside of scoped group"
                  . $lineStr
                );
              }
              break;
            }
            case "access": {
              if ($depth < 2 || $groups[$depth - 2] != "client"
                || $client == null) {
                throw new ConfigParseException(
                  "Group '" . $group . "' cannot be a subgroup" . $lineStr
                );
              }
              $access = new UserAccess();
              break;
            }
            case "client": {
              if ($depth > 1) {
                throw new ConfigParseException(
                  "Group '" . $group . "' cannot be a subgroup" . $lineStr
                );
              }
              $client = new BNETClient();
              break;
            }
            default: {
              throw new ConfigParseException(
                "Undefined group '" . $group . "'" . $lineStr
              );
            }
          }

          continue;

        }

        if ($line == "}") {

          switch (strtolower($group)) {
            case "": break;
            case "access": {
              $client->acl[] = $access;
              break;
            }
            case "client": {
              self::$clients[] = $client;
            }
            default: {
              throw new ConfigParseException(
                "Undefined group '" . $group . "'" . $lineStr
              );
            }
          }

          array_pop($groups);
          $depth -= 1;

          if (count($groups) > 0) {
            $group = end($groups);
          } else {
            $group = null;
          }

          continue;

        }

        $cursor = strpos($line, "=");
        $key    = trim(substr($line, 0, $cursor));
        $val    = trim(substr($line, $cursor + 1));

        $cursor = strpos($val, "#");
        if ($cursor !== false) {
          $val = substr($val, 0, $cursor - 1);
        }
        $val = rtrim($val);

        if ($depth == 0) {
          throw new ConfigParseException(
            "Global scope directives are not supported" . $lineStr
          );
        }

        switch (strtolower($group)) {
          case "": {
            switch (strtolower($key)) {
              case "logPackets": {
                self::$logPackets = self::strToBool($val);
                if (self::$logPackets) {
                  fwrite(STDERR, "Packet logging enabled!\n");
                }
                break;
              }
              case "trigger": {
                self::$trigger = $val;
                break;
              }
              default: {
                throw new ConfigParseException(
                  "Undefined directive '" . $key . "' in global scope"
                  . $lineStr
                );
              }
            }
            break;
          }
        }

      }

    } catch (Exception $ex) {
      throw new KaleidoscopeException($ex);
    }

  }

}