<?php

session_start();
include("./config.php");

$contentPage = "";
if (isset($_REQUEST["id"])) {
  $sql = "SELECT * FROM contents WHERE id = :id";
  $stmt = $pdoConn->prepare($sql);
  $stmt->bindParam(":id", $_REQUEST["id"]);
  $stmt->execute();
  $result = $stmt->fetchAll();
  $contentPage = $result[0]["content"];
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <title>Web View</title>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" type="text/css" href="/webview/vendor/bootstrap/css/bootstrap.min.css" />
  <link rel="stylesheet" type="text/css" href="/webview/css/main.css?v=3" />
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