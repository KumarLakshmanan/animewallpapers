<?php
$facility = $_REQUEST['facility'];
$sql = "SELECT * FROM contents WHERE type=$facility ORDER BY contents.sindex DESC";
$stmt = $pdoConn->prepare($sql);
$stmt->execute();
$result = $stmt->fetchAll();
?>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="white-box text-end">
            <a href="<?= $adminBaseUrl ?>addcontent?type=<?= $facility ?>" class="btn btn-success text-white">
                <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 32 32">
                    <path fill="currentColor" d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z" />
                </svg>
                Add new content
            </a>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">Content</h3>
            </div>
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Icon</th>
                            <th class="border-top-0">Title</th>
                            <th class="border-top-0">Type</th>
                            <th class="border-top-0">Created At</th>
                            <th class="border-top-0">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        foreach ($result as $key => $value) {
                            echo '<tr>';
                            echo "<td>" . ($value['sindex']) . "</td>";
                            echo "<td><a href='" . $baseUrl . "uploads/images/" . $value['icon'] . "' target='_blank'><img src='" . $baseUrl . "uploads/images/" . $value['icon'] . "' width='50' height='50' /></a></td>";
                            echo "<td>" . $value['title'] . "</td>";
                            echo "<td>";
                            if ($value['type'] == 1) {
                                echo "About us";
                            } else {
                                echo "Facility";
                            }
                            echo "</td>";
                            echo "<td>" . date('d-m-Y', strtotime($value['created_at'])) . "</td>";
                            echo "<td>";
                            echo '<a href="' . $adminBaseUrl . 'editcontent?contentid=' . $value['id'] . '&type=1" class="btn btn-primary btn-sm text-white">Edit</a>';
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
    });

    function deleteAdmin(id) {
        swal({
            title: 'Are you sure you want to delete this content?',
            text: "The content will be deleted permanently. and you won't be able to recover it.",
            icon: 'warning',
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                $.ajax({
                    url: "<?= $apiUrl ?>",
                    type: 'POST',
                    data: {
                        mode: 'deletecontent',
                        contentid: id,
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