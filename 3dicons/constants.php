<?php
define('HOSTNAME', 'localhost');
date_default_timezone_set('Europe/London');
define("DELIVERY_RADIUS", 5000);
define('SITE_URL', 'https://svgrepo.frontendforever.com/');
define('CDN_URL', 'https://svgrepo.frontendforever.com/cdn/');
define('DB_HOST', 'localhost');
define('DB_DATABASE', 'u707479837_svgrepo');
define('DB_USERNAME', 'u707479837_svgrepo');
define('DB_PASSWORD', 'Uf9g!&0wP');
define("BASE_PATH", "/home/u707479837/domains/frontendforever.com/public_html/subdomains/svgrepo/");
define("SERVER_PATH", "/home/u707479837/domains/frontendforever.com/public_html/subdomains/");
define("CDN_PATH", "/home/u707479837/domains/frontendforever.com/public_html/subdomains/svgrepo/cdn/");
define("LOCAL_CDN_URL", "http://svgrepo.frontendforever.com/cdn/");

$phoneRegex = "/^[0-9]{10}$/";
$pincodeRegex = "/^[0-9]{6}$/";
$pancardRegex = "/^([a-zA-Z]){5}([0-9]){4}([a-zA-Z]){1}?$/";
$ifscRegex = "/^([A-Za-z]){4}([0-9]){7}?$/";
$gstRegex = "/^([0-9]){2}([a-zA-Z]){5}([0-9]){4}([a-zA-Z]){1}([1-9]){1}([a-zA-Z]){1}([0-9a-zA-Z]){1}?$/";
$bankAccountRegex = "/^([0-9]){9,18}?$/";
$emailRegex = "/^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/";
$amountRegex = "/^[0-9]+(\.[0-9]{1,2})?$/";
$addressRegex = "/^[a-zA-Z0-9\s\,\.\-\/\(\)\&\#]+$/";
$upiRegex = "/^([a-zA-Z0-9-.]){1,50}@([a-zA-Z0-9-]){1,10}$/";
$bankNameRegex = "/^[a-zA-Z0-9\s\,\.\-\/\(\)\&\#]+$/";
$datetime = date('Y-m-d H:i:s');
$date = date('Y-m-d');
$gstNoRegex = "/^([0-9]){2}([a-zA-Z]){5}([0-9]){4}([a-zA-Z]){1}([1-9]){1}([a-zA-Z]){1}([0-9a-zA-Z]){1}?$/";
$fssaiNoRegex = "/^([0-9]){14}?$/";


if ($_SERVER['HTTP_HOST'] == 'localhost') {
    $apiUrl  = "http://localhost/spk-admin/3dicons/v1.php";
    $baseUrl  = "http://localhost/spk-admin/";
    $webAddress = "http://localhost/spk-admin/";
    $uploadsDirectory = "/Applications/XAMPP/xamppfiles/htdocs/spk-admin/uploads/";
} else {
    $apiUrl  = "https://svgrepo.frontendforever.com/3dicons/v1.php";
    $baseUrl  = "https://svgrepo.frontendforever.com/3dicons/";
    $webAddress = "https://svgrepo.frontendforever.com/3dicons/";
    $uploadsDirectory = "/home/u707479837/public_html/subdomains/svgrepo/uploads/";
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
