<?php

session_start();
ini_set('log_errors', true);
ini_set('error_log', './php-error.log');
include("./config.php");

if (isset($_REQUEST["id"])) {
    try {
        $id = $_REQUEST["id"];
        $sql = "SELECT * FROM users WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        $result = $stmt->fetch();
?>
        <div class="text-center">
            <?php
            if ($result["image"] != "") {
            ?>
                <img src="<?php echo $baseUrl . "uploads/images/" . $result["image"]; ?>" alt="user" class="img-circle" width="150" />
            <?php
            }
            ?>
        </div>
        <table class="table table-striped">
            <tr>
                <td>Name</td>
                <td>:</td>
                <td><?php echo $result["fullname"]; ?></td>
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
                <td>Department</td>
                <td>:</td>
                <td><?php echo $result["department"]; ?></td>
            </tr>
            <tr>
                <td>Gender</td>
                <td>:</td>
                <td><?php echo $result["gender"]; ?></td>
            </tr>
            <tr>
                <td>Blood Group</td>
                <td>:</td>
                <td><?php echo $result["bloodgroup"]; ?></td>
            </tr>
            <tr>
                <td>Willing To Donate</td>
                <td>:</td>
                <td><?php echo $result["willingtodonate"] == 1 ? "Yes" : "No"; ?></td>
            </tr>
            <tr>
                <td>Course Type</td>
                <td>:</td>
                <td><?php echo $result["coursetype"]; ?></td>
            </tr>
            <?php
            if ($result["type"] == "staff" || $result["type"] == "alumni") {
            ?>
                <tr>
                    <td>Job Nature</td>
                    <td>:</td>
                    <td><?php echo $result["working"]; ?></td>
                </tr>
            <?php
            }
            if ($result["type"] == "student" || $result["type"] == "alumni") {
            ?>
                <tr>
                    <td>Grade</td>
                    <td>:</td>
                    <td><?php echo $result["grade"]; ?></td>
                </tr>
            <?php
            } else if ($result["type"] == "staff") {
            ?>
                <tr>
                    <td>Staff Type</td>
                    <td>:</td>
                    <td><?php echo $result["stafftype"]; ?></td>
                </tr>
            <?php
            }
            if ($result["type"] == "student" || $result["type"] == "alumni") {
            ?>
                <tr>
                    <td>Batch</td>
                    <td>:</td>
                    <td><?php echo $result["joiningyear"]; ?></td>
                </tr>
            <?php
            } else if ($result["type"] == "staff") {
            ?>
                <tr>
                    <td>Joining Year</td>
                    <td>:</td>
                    <td><?php echo $result["joiningyear"]; ?></td>
                </tr>
            <?php
            }
            ?>
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
}
