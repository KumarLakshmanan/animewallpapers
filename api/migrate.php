<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    include("./config.php");
    $db = new Connection();
    $conn = $db->getConnection();
    $fileJson = file_get_contents("../data.json");
    $data = json_decode($fileJson, true);
    $newjson = [];
    $sql = "TRUNCATE TABLE `tnscert_books`";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    for ($i=0; $i < count($data); $i++) {
        $filepath = "../uploads/pdf/" . $data[$i]["content_name"];
        if (file_exists($filepath)) {
            $fileSize = filesize($filepath);
            $fileSize = round($fileSize / 1024, 2);
            $fileSize = $fileSize;
            $totalPages = "";
            $sql = "INSERT INTO `tnscert_books` (`class`, `term`, `medium`, `content_name`, `content_name_s3`, `file_type`, `label`, `file_size`, `pages`) VALUES (:class, :term, :medium, :content_name, :content_name_s3, :file_type, :label, :file_size, :pages)";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':class', $data[$i]["class"]);
            $stmt->bindParam(':term', $data[$i]["term"]);
            $stmt->bindParam(':medium', $data[$i]["medium"]);
            $stmt->bindParam(':content_name', $data[$i]["content_name"]);
            $stmt->bindParam(':content_name_s3', $data[$i]["content_name_s3"]);
            $stmt->bindParam(':file_type', $data[$i]["file_type"]);
            $stmt->bindParam(':label', $data[$i]["label"]);
            $stmt->bindParam(':file_size', $fileSize);
            $stmt->bindParam(':pages', $totalPages);
            $stmt->execute();
        } else {
            $newjson[] = $data[$i];
            echo "File not found: " . $filepath . "\n";
        }
    }
    file_put_contents("../nofiles.json", json_encode($newjson));
}

function countPdfPages($path) {
  $pdf = file_get_contents($path);
  $number = preg_match_all("/\/Page\W/", $pdf, $dummy);
  return $number;
}