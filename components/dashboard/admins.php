<?php

$admintype = $_REQUEST['admintype'] ?? "";

if ($admintype == "") {
    $sql = "SELECT * FROM admins WHERE role != 'admin' ORDER BY admins.departmenttype DESC";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $result = $stmt->fetchAll();
} else {
    $sql = "SELECT * FROM admins WHERE role != 'admin' AND departmenttype = :admintype ORDER BY admins.sindex ASC";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute(['admintype' => $admintype]);
    $result = $stmt->fetchAll();
}
?>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="white-box text-end">
            <a href="<?= $adminBaseUrl ?>addadmin" class="btn btn-success text-white">
                <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 32 32">
                    <path fill="currentColor" d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z" />
                </svg>
                Add new admin
            </a>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">Admins</h3>
            </div>
            <div class="col-md-6">
                <div class="p-2">
                    <h6>Type*</h6>
                    <select class="form-select" id="type" aria-label="Default select example">
                        <option>Select Department</option>
                        <option value="1" <?= $admintype == "1" ? "selected" : "" ?>>Aided Department</option>
                        <option value="2" <?= $admintype == "2" ? "selected" : "" ?>>Self Financing Department</option>
                        <option value="3" <?= $admintype == "3" ? "selected" : "" ?>>Extension Department</option>
                        <option value="4" <?= $admintype == "4" ? "selected" : "" ?>>Clubs & Other Forums</option>
                    </select>
                </div>
            </div>
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Seniority</th>
                            <th class="border-top-0">Profile</th>
                            <th class="border-top-0">Name</th>
                            <th class="border-top-0">Type</th>
                            <th class="border-top-0">Email</th>
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
                            echo "<td><img src='" . $baseUrl . "uploads/images/" . $value['profile'] . "' width='50' height='50' /></td>";
                            echo "<td>" . $value['fullname'] . "</td>";
                            echo "<td>";
                            if ($value['departmenttype'] == "1") {
                                echo 'Aided';
                            } else if ($value['departmenttype'] == '2') {
                                echo 'Self';
                            } else if ($value['departmenttype'] == '3') {
                                echo 'Extension';
                            } else {
                                echo 'Clubs';
                            }
                            echo "</td>";
                            echo "<td>" . $value['email'] . "</td>";
                            echo "<td>" . date('d-m-Y', strtotime($value['created_at'])) . "</td>";
                            echo "<td>";
                            echo '<a href="' . $adminBaseUrl . 'editadminabout?adminid=' . $value['id'] . '" class="btn m-1 btn-secondary btn-sm text-white">About</a>';
                            echo '<a href="' . $adminBaseUrl . 'editadminsocial?adminid=' . $value['id'] . '" class="btn m-1 btn-success btn-sm text-white">Social Media</a>';
                            echo "<br>";
                            echo '<a href="' . $adminBaseUrl . 'editadmin?adminid=' . $value['id'] . '" class="btn m-1 btn-primary btn-sm text-white">Edit</a>';
                            if ($value['isClub'] == '1') {
                                echo '<a href="' . $adminBaseUrl . 'editadminstaff?adminid=' . $value['id'] . '" class="btn m-1 btn-success btn-sm text-white">Staffs</a>';
                            }
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
        $("#type").change(function() {
            var departmentid = $(this).val();
            window.location.href = "<?= $adminBaseUrl ?>admins?admintype=" + departmentid;
        });
    });

    function deleteAdmin(id) {
        swal({
            title: 'Are you sure you want to delete this admin?',
            text: "The admin will be deleted permanently!",
            icon: 'warning',
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                $.ajax({
                    url: "<?= $apiUrl ?>",
                    type: 'POST',
                    data: {
                        mode: 'deleteadmin',
                        adminid: id,
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