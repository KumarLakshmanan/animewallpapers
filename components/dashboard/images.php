<?php


$sql = "SELECT * FROM images ORDER BY id DESC LIMIT 100";
$stmt = $pdoConn->prepare($sql);
$stmt->execute();
$result = $stmt->fetchAll();
?>

<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="white-box text-end">
            <a href="<?= $adminBaseUrl ?>addimage" class="btn btn-success text-white">
                <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 32 32">
                    <path fill="currentColor" d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z" />
                </svg>
                Add new image
            </a>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">All images</h3>
            </div>
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Category Id</th>
                            <th class="border-top-0">Sub Category Id</th>
                            <th class="border-top-0">Name</th>
                            <th class="border-top-0">Views</th>
                            <th class="border-top-0">Likes</th>
                            <th class="border-top-0">Actions</th>
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
                                    echo $value['subcategory_id'];
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    echo $value['name'];
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    echo $value['views'];
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    echo $value['likes'];
                                    ?>
                                </td>
                                <td>
                                    <a href="<?= $adminBaseUrl ?>editimage?imageid=<?= $value['id'] ?>" class="btn btn-info">
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
                imageid: $id,
                mode: 'deleteimage'
            },
            success: function(data) {
                if (data.error.code == '#200') {
                    location.reload();
                }
            }
        });
    }
</script>