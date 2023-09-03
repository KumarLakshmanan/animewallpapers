<?php

session_start();
ini_set('log_errors', true);
ini_set('error_log', './php-error.log');
include("./config.php");

if (isset($_REQUEST["id"])) {
    try {
        $id = $_REQUEST["id"];
        $sql = "SELECT * FROM contact WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        $result = $stmt->fetch();
        $sql = "UPDATE contact SET status = 'read' WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
?>
        <table class="table table-striped">
            <tr>
                <td>Name</td>
                <td>:</td>
                <td><?php echo $result["name"]; ?></td>
            </tr>
            <tr>
                <td>Email</td>
                <td>:</td>
                <td><?php echo $result["email"]; ?></td>
            </tr>
            <tr>
                <td>Contact No</td>
                <td>:</td>
                <td><?php echo $result["phone"]; ?></td>
            </tr>
            <tr>
                <td>Message</td>
                <td>:</td>
                <td><?php echo $result["message"]; ?></td>
            </tr>
            <tr>
                <td>Created At</td>
                <td>:</td>
                <td><?php echo date('d M h:i A', strtotime($result["created_at"])); ?></td>
            </tr>
        </table>
<?php
    } catch (Exception $e) {
        $json["error"] = array("code" => "#500", "description" => $e->getMessage());
    }
} else {
    echo "No data found";
}