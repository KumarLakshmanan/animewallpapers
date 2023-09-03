<?php

if (!isset($_SESSION)) {
    session_start();
}
include("constant.php");
date_default_timezone_set('Asia/Kolkata');
error_reporting(1);
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);


header("Content-type: application/json");
$json["data"] = [];

$json["error"] = array("code" => "#200", "description" => "Success.");
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    include("./config.php");
    if (isset($_FILES['image']) && isset($_GET['auth']) && isset($_GET['type'])) {
        $authId = $_GET['auth'];
        $type = $_GET['type'];
        $file = $_FILES['image'];
        $fileName = $file['name'];
        $fileTmpName = $file['tmp_name'];
        $fileSize = $file['size'];
        $extensions = array("jpg", "jpeg", "png", "gif");
        $fileExt = explode('.', $fileName);
        $fileActualExt = PATHINFO($fileName, PATHINFO_EXTENSION);
        $fileNameNew = time() . "_" . uniqid('', true) . "." . $fileActualExt;
        $target_dir = $uploadsDirectory . "images/";
        $fileDestination = $target_dir . $fileNameNew;
        if (in_array($fileActualExt, $extensions)) {
            if ($fileSize < 1024 * 1024 * 100) {
                if (move_uploaded_file($fileTmpName, $fileDestination)) {
                    $json["data"] = array("id" => $fileNameNew, "image_url" => $baseUrl . "uploads/images/" . $fileNameNew, "type" => $fileExt, "size" => $fileSize);
                } else {
                    $json["error"] = array("code" => "#500", "description" => "Error uploading file.");
                }
            } else {
                $json["error"] = array("code" => "#500", "description" => "File size is too big.");
            }
        } else {
            $json["error"] = array("code" => "#500", "description" => "File type is not supported.");
        }
    }
}

echo json_encode($json);
