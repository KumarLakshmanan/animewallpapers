<?php

$sql = "SELECT * FROM subcategories ORDER BY id DESC";
$stmt = $pdoConn->prepare($sql);
$stmt->execute();
$result = $stmt->fetchAll();
?>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="white-box">
            <div class="text-end">
                <a href="<?= $adminBaseUrl ?>addsubcategory" class="btn btn-success text-white">
                    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 32 32">
                        <path fill="currentColor" d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z" />
                    </svg>
                    Add New Sub Category
                </a>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">All Sub Categories</h3>
            </div>
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Category id</th>
                            <th class="border-top-0">Sub Category Name</th>
                            <th class="border-top-0">Image</th>
                            <th class="border-top-0">Created Date</th>
                            <th class="border-top-0">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        foreach ($result as $key => $value) {
                        ?>
                            <tr>
                                <td><?php echo $key + 1; ?></td>

                                <td>
                                    <?php
                                    echo $value['category_id'];
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    echo $value['name'];
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    $images = explode(',', $value['thumbnail']);
                                    foreach ($images as $key => $image) {
                                        if ($image != '') {
                                    ?>
                                            <a href="<?php echo $baseUrl . "uploads/images/" . $image; ?>" target="_blank">
                                                <?php echo "Image " . ($key + 1); ?>
                                            </a>
                                    <?php
                                        }
                                    }
                                    ?>
                                </td>
                                <td><?php echo date('d M h:i A', strtotime($value['created_at'])); ?></td>
                                <td>
                                    <a href="<?= $adminBaseUrl ?>editsubcategory?subcategoryid=<?= $value['id'] ?>" class="btn btn-info">
                                        <i class="fa fa-edit"></i>
                                    </a>
                                    <a href="#" onclick="if(confirm('Are you sure to delete ?')){deleteCode('<?= $value['id'] ?>')}" class="btn btn-danger">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        <?php
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

    function deleteCode($id) {
        $.ajax({
            url: "<?= $apiUrl ?>",
            type: 'POST',
            data: {
                subcategoryid: $id,
                mode: 'deletesubCategory'
            },
            success: function(data) {
                if (data.error.code == '#200') {
                    swal({
                        title: 'Success!',
                        icon: 'success',
                        text: "Jobs deleted successfully",
                        confirmButtonText: 'Ok'
                    }).then((result) => {
                        location.reload();
                    });
                }
            }
        });
    }
</script>