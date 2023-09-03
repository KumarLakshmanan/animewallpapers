<?php

if ($_SERVER['HTTP_HOST'] == 'localhost') {
    $apiUrl  = "http://localhost/spk-admin/api/v1.php";
    $baseUrl  = "http://localhost/spk-admin/";
    $adminBaseUrl  = "http://localhost/spk-admin/";
    $webAddress = "http://localhost/spk-admin/";
    $codesDirectory = "/Applications/XAMPP/xamppfiles/htdocs/spk-admin/code/";
    $uploadsDirectory = "/Applications/XAMPP/xamppfiles/htdocs/spk-admin/uploads/";
    $baseDirectory = "/Applications/XAMPP/xamppfiles/htdocs/spk-admin/";
} else {
    $apiUrl  = "https://animewallpapers.codingfrontend.in/api/v1.php";
    $baseUrl  = "https://animewallpapers.codingfrontend.in/";
    $adminBaseUrl  = "https://animewallpapers.codingfrontend.in/";
    $webAddress = "https://animewallpapers.codingfrontend.in/";
    $codesDirectory = "/home/u707479837/public_html/subdomains/spkc/code/";
    $uploadsDirectory = "/home/u707479837/public_html/subdomains/spkc/uploads/";
    $baseDirectory = "/home/u707479837/public_html/subdomains/spkc/";
}



$getErrorCode =  array("code" => "#101", "description" => "Get request not allowed.");
$postErrorCode =  array("code" => "#102", "description" => "Post request not allowed.");
$invalidRequestErrorCode =  array("code" => "#103", "description" => "Invalid request.");
$invalidTokenErrorCode =  array("code" => "#104", "description" => "Invalid token.");
$invalidUsernameErrorCode =  array("code" => "#105", "description" => "Invalid username.");
$unauthorizedErrorCode =  array("code" => "#105", "description" => "Unauthorized access.");
$invalidIdErrorCode =  array("code" => "#106", "description" => "Invalid id.");
$invalidEmailErrorCode =  array("code" => "#107", "description" => "Invalid email.");
$invalidPasswordErrorCode =  array("code" => "#108", "description" => "Invalid password.");
$invalidPhoneErrorCode =  array("code" => "#109", "description" => "Invalid phone.");
$invalidNameErrorCode =  array("code" => "#110", "description" => "Invalid name.");
$invalidCategoryErrorCode =  array("code" => "#111", "description" => "Invalid category.");
$invalidUserOrPass =  array("code" => "#112", "description" => "Invalid username or password.");
$somethingWentWrong =  array("code" => "#113", "description" => "Something went wrong.");
$permissionDenied =  array("code" => "#114", "description" => "Permission denied.");
$fileNotFound =  array("code" => "#115", "description" => "File not found.");
$pleaseFillAll =  array("code" => "#116", "description" => "Please fill all the fields.");
$successErrorCode =  array("code" => "#200", "description" => "Success.");

$webName = "SPK College";
$webLogo = $webAddress . "/img/logo-white.png";
$webDescription = "SPK College";
