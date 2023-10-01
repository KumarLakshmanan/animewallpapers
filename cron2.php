<?php

$jsonData = [];
$success = 0;
$fail = 0;

$db_name = "u707479837_animewallpaper";
$db_user = "u707479837_animewallpaper";
$db_pass = "S9TdVu~8J";
$db_host = "localhost";
$pdo = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);

$sql = "SELECT * FROM `alphawallpapers2` WHERE `isavailable` = 0 ORDER BY `id` DESC";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$jsonData = $stmt->fetchAll(PDO::FETCH_ASSOC);

for ($i = 0; $i < count($jsonData); $i++) {
    $image = $jsonData[$i]['image'];
    $thumb = $jsonData[$i]['thumb'];
    $isFailed = false;

    // Make a GET request to download the image
    $imageContent = file_get_contents($image);
    if ($imageContent === false) {
        // Failed to download the image
        $failedData[] = $jsonData[$i];
        $isFailed = true;
        $fail++;
    } else {
        // Save the image to the 'images' directory
        file_put_contents('uploads/wallpaper/' . basename($image), $imageContent);

        $imageUrl = 'https://animewallpapers.codingfrontend.in/uploads/wallpaper/' . basename($image);
        $sql = "UPDATE `alphawallpapers2` SET `image` = :image, `thumb` = :thumb, `isavailable` = 1 WHERE `id` = :id";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':image' => $imageUrl,
            ':thumb' => $imageUrl,
            ':id' => $jsonData[$i]['id']
        ]);
    }
    if ($isFailed) {
        $sql = "UPDATE `alphawallpapers2` SET `isavailable` = 2 WHERE `id` = :id";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':id' => $jsonData[$i]['id']
        ]);
    }
}

echo "Success: $success, Fail: $fail\n";
