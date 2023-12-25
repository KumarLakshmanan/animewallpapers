<?php
@ob_start();
@session_start();
error_reporting(E_ALL & ~E_NOTICE);
error_reporting(E_ERROR | E_WARNING | E_PARSE);
@ini_set("display_startup_errors", "1");
@ini_set('display_errors', 'On');
@ini_set('error_reporting', 1);
@ini_set('error_log', dirname(__FILE__) . '/error_log.txt');
@ini_set('error_reporting', E_ALL);
include_once("constants.php");

$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_EMULATE_PREPARES => false,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci; SET SESSION sql_mode = ''; SET SESSION time_zone = '+05:30';"
];
$pdoConn = new PDO("mysql:host=" . HOSTNAME . ";dbname=" . DB_DATABASE, DB_USERNAME, DB_PASSWORD, $options);
$pdoConn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$pdoConn->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
$pdoConn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
$pdoConn->exec("SET NAMES 'utf8'");
$pdoConn->exec("SET CHARACTER SET utf8");
$pdoConn->exec("SET SESSION collation_connection = 'utf8_general_ci'");
$pdoConn->exec("SET SESSION sql_mode = ''");
$pdoConn->exec("SET SESSION time_zone = '+01:00'");
global $pdoConn;
include('functions.php');
