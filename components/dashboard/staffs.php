<?php

$departmentid = $_REQUEST['departmentid'] ?? "";
if ($_SESSION['role'] == "admin") {
} else {
    $departmentid = $_SESSION['id'];
}
if ($departmentid != "") {
    $sql = "SELECT * FROM staffs WHERE departmentid = :departmentid ORDER BY staffs.id DESC";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute(['departmentid' => $departmentid]);
    $result = $stmt->fetchAll();
} else {
    $sql = "SELECT * FROM staffs ORDER BY staffs.id DESC";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $result = $stmt->fetchAll();
}
?>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="white-box text-end">
            <a href="<?= $adminBaseUrl ?>addstaff" class="btn btn-success text-white">
                <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 32 32">
                    <path fill="currentColor" d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z" />
                </svg>
                Add new staff
            </a>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">Staffs</h3>
            </div>
            <?php
            if ($_SESSION['role'] == "admin") {
            ?>
                <div class="col-md-6">
                    <select class="form-select" id="department" aria-label="Default select example">
                        <option value="0">Select Department</option>
                        <option value="iqac">IQAC</option>
                        <?php
                        $sql = "SELECT * FROM admins WHERE role != 'admin'";
                        $stmt = $pdoConn->prepare($sql);
                        $stmt->execute();
                        $departments = $stmt->fetchAll();
                        foreach ($departments as $department) {
                        ?>
                            <option value="<?= $department['id'] ?>" <?= $departmentid == $department['id'] ? "selected" : "" ?>><?= $department['fullname'] ?>
                                <?php
                                if ($department['departmenttype'] == "1") {
                                    echo "(Aided)";
                                } elseif ($department['departmenttype'] == "2") {
                                    echo "(Self)";
                                }
                                ?>
                            </option>
                        <?php
                        }
                        ?>
                    </select>
                </div>
            <?php
            }
            ?>
            <div class="p-3"></div>
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Seniority</th>
                            <th class="border-top-0">Name</th>
                            <th class="border-top-0">Position</th>
                            <th class="border-top-0">Qualification</th>
                            <th class="border-top-0">Department</th>
                            <th class="border-top-0">Created At</th>
                            <th class="border-top-0">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        foreach ($result as $key => $value) {
                            echo '<tr>';
                            echo "<td>" . ($key + 1) . "</td>";
                            echo "<td>" . $value['sindex'] . "</td>";
                            echo "<td>" . $value['name'] . "</td>";
                            echo "<td>" . $value['position'] . "</td>";
                            echo "<td>" . $value['qualification'] . "</td>";
                            echo "<td>" . $value['departmentname'] . "</td>";
                            echo "<td>" . date('d-m-Y', strtotime($value['created_at'])) . "</td>";
                            echo "<td>";
                            echo '<a href="' . $adminBaseUrl . 'editstaff?staffid=' . $value['id'] . '" class="btn btn-primary btn-sm text-white">Edit</a>';
                            echo '<button class="btn btn-danger btn-sm text-white" onclick="deleteAdmin(' . $value['id'] . ')">Delete</button>';
                            echo "</td>";
                            echo '</tr>';
                        }
                        ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<script>
    $(document).ready(function() {
        $('#bDataTable').DataTable();
        $("#department").change(function() {
            var departmentid = $(this).val();
            window.location.href = "<?= $adminBaseUrl ?>staffs?departmentid=" + departmentid;
        });
    });

    function deleteAdmin(id) {
        swal({
            title: 'Are you sure you want to delete this staff?',
            text: "The staff will be deleted permanently!",
            icon: 'warning',
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                $.ajax({
                    url: "<?= $apiUrl ?>",
                    type: 'POST',
                    data: {
                        mode: 'deletestaff',
                        staffid: id,
                    },
                    success: function(data) {
                        if (data.error.code == '#200') {
                            location.reload();
                        }
                    }
                });
            }
        });
    }
</script>