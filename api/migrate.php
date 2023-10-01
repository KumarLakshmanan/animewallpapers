<?php

session_start();
ini_set('log_errors', true);
ini_set('error_log', './php-error.log');
include("./config.php");


$jsonData = file_get_contents('mobile_walle_images.json');
$data = json_decode($jsonData, true);

foreach ($data as $category) {
    foreach ($category['subcategories'] as $subcategory) {
        $sql = "INSERT INTO allwallpapers (title, thumb, image, alt, subcategorylink, subcategoryname, categorylink, categoryname, width, height) VALUES ";
        foreach ($subcategory['images'] as $wallpaper) {
            $title = str_replace("'", "\'", $wallpaper['title']);
            $thumb = str_replace("'", "\'", $wallpaper['src']);
            $image = str_replace("'", "\'", str_replace("thumb-", "", $wallpaper['src']));
            $alt = str_replace("'", "\'", $wallpaper['alt']);
            $subcategorylink = str_replace("'", "\'", $subcategory['link']);
            $subcategoryname = str_replace("'", "\'", $subcategory['name']);
            $categorylink = str_replace("'", "\'", $category['link']);
            $categoryname = str_replace("'", "\'", $category['ratio']);
            $width = str_replace("'", "\'", $category['width']);
            $height = str_replace("'", "\'", $category['height']);

            $sql .= "('" . $title . "', '" . $thumb . "', '" . $image . "', '" . $alt . "', '" . $subcategorylink . "', '" . $subcategoryname . "', '" . $categorylink . "', '" . $categoryname . "', '" . $width . "', '" . $height . "'), ";
        }
        $sql = rtrim($sql, ", ") . ";";
        if (count($subcategory['images']) > 0) {
            $stmt = $pdoConn->prepare($sql);
            $stmt->execute();
        }
    }
}
