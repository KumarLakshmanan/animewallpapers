<?php

session_start();
include("./config.php");
$adminid = $_REQUEST["id"];
$directory = $baseDirectory . "/json/staff/";
if (!file_exists($directory)) {
  mkdir($directory, 0777, true);
}

$filename = $directory . $adminid . ".json";
if (file_exists($filename)) {
  $json = file_get_contents($filename);
  $json = json_decode($json, true);
  $contentPage = $json["content"];
} else {
  $contentPage = "";
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <title>Department About</title>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <!--===============================================================================================-->
  <link rel="stylesheet" type="text/css" href="/webview/vendor/bootstrap/css/bootstrap.min.css" />
  <!--===============================================================================================-->
  <link rel="stylesheet" type="text/css" href="/webview/fonts/font-awesome-4.7.0/css/font-awesome.min.css" />
  <link rel="stylesheet" type="text/css" href="/webview/css/util.css" />
  <link rel="stylesheet" type="text/css" href="/webview/css/main.css?v=2" />
</head>

<body>
  <div class="contact1">
    <div class="container-contact1 text-center">
      <div>
        <br />
        <?= $contentPage ?>
      </div>
    </div>
  </div>
</body>

</html>