<?php
session_start();
include("api/config.php");
$db = new Connection();
$conn = $db->getConnection();

if (isset($_SESSION['id']) && $_SESSION['role'] == 'admin') {
    $currentTime = time();
    $authId = $_SESSION['token'];
    $username = $_SESSION['email'];
    $userAuth  = validateSessionToken($conn, $authId, $username);
    if ($userAuth) {
        include("components/dashboard.php");
        exit();
    } else {
        include("components/login.php");
        exit();
    }
} else {
    include("components/login.php");
    exit();
}
