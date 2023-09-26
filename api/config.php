<?php
if (!isset($_SESSION)) {
    session_start();
}
include("constant.php");
date_default_timezone_set('Asia/Kolkata');
error_reporting(1);
error_reporting(E_ALL);
ini_set('log_errors', 'On');
ini_set('error_log', $baseDirectory . 'api/error.log');
class Connection
{
    private $db;
    public function __construct()
    {
        $db_name = "u707479837_coupleprofiles";
        $db_user = "u707479837_coupleprofiles";
        $db_pass = "Kumar@2003";
        $this->db = new PDO('mysql:host=127.0.0.1;dbname=' . $db_name, $db_user, $db_pass);
        $this->db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
        $this->db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    }
    public function __destruct()
    {
        $this->db = null;
    }
    public function getConnection()
    {
        return $this->db;
    }
    public function getAll($table)
    {
        $sql = "SELECT * FROM $table";
        $stmt = $this->db->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll();
    }
    public function getAllFromWhere($table, $column, $value, $order = null)
    {
        $sql = "SELECT * FROM $table WHERE $column = :value";
        if ($order) {
            $sql .= " ORDER BY $order";
        }
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':value', $value);
        $stmt->execute();
        return $stmt->fetchAll();
    }
    public function getAllFromWhere2($table, $column, $value, $column2, $value2, $order = null)
    {
        $sql = "SELECT * FROM $table WHERE $column = :value AND $column2 = :value2";
        if ($order) {
            $sql .= " ORDER BY $order";
        }
        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':value', $value);
        $stmt->bindParam(':value2', $value2);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}


function getSessionToken($db, String $username, int $id)
{
    $created_at = date('Y-m-d H:i:s');
    $token = md5($username . $id . $created_at);
    // more than 2 days old
    $sql = "DELETE FROM `sessions` WHERE AuthId = :id AND created_at < DATE_SUB(NOW(), INTERVAL 2 DAY)";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    $ip = getClientIP();
    $sql = "INSERT INTO `sessions` (`AuthId`, `AuthUsername`, `AuthKey`, `created_at`, `ip_addr`) VALUES (:id, :username, :token, :created_at, :ip)";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':username', $username);
    $stmt->bindParam(':token', $token);
    $stmt->bindParam(':created_at', $created_at);
    $stmt->bindParam(':ip', $ip);
    $stmt->execute();
    return $token;
}

function validateSessionToken($db, String $token, $username = null)
{
    $sql = "SELECT * FROM `sessions` WHERE `AuthKey` = :token LIMIT 1";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':token', $token);
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($stmt->rowCount() > 0) {
        if ($result['AuthUsername'] == $username) {
            return $result;
        }
    }
    return false;
}


function getClientIP()
{
    $ipAddress = '';
    if (isset($_SERVER['HTTP_CLIENT_IP']))
        $ipAddress = $_SERVER['HTTP_CLIENT_IP'];
    else if (isset($_SERVER['HTTP_X_FORWARDED_FOR']))
        $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if (isset($_SERVER['HTTP_X_FORWARDED']))
        $ipAddress = $_SERVER['HTTP_X_FORWARDED'];
    else if (isset($_SERVER['HTTP_FORWARDED_FOR']))
        $ipAddress = $_SERVER['HTTP_FORWARDED_FOR'];
    else if (isset($_SERVER['HTTP_FORWARDED']))
        $ipAddress = $_SERVER['HTTP_FORWARDED'];
    else if (isset($_SERVER['REMOTE_ADDR']))
        $ipAddress = $_SERVER['REMOTE_ADDR'];
    else
        $ipAddress = 'UNKNOWN';
    return $ipAddress;
}

function validateSession($db)
{
    if (!isset($_SESSION)) {
        session_start();
    }
    if (isset($_SESSION['token'])) {
        return true;
    } else if (isset($_COOKIE['token']) && isset($_COOKIE['email'])) {
        $token = $_COOKIE['token'];
        $email = $_COOKIE['email'];
        $userAuth = validateSessionToken($db, $token, $email);
        if ($userAuth) {
            $sql = "SELECT * FROM users WHERE email = :email";
            $stmt = $db->prepare($sql);
            $stmt->bindParam(':email', $email);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $_SESSION['id'] = $result["id"];
            $_SESSION['email'] = $result["email"];
            $_SESSION['fullname'] = $result["fullname"];
            $_SESSION['username'] = $result["username"];
            $_SESSION['email'] = $result["email"];
            $_SESSION['role'] = $result["role"];
            $_SESSION['token'] = $token;
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}
