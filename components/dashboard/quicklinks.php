<?php

$sql = "SELECT * FROM links ORDER BY id DESC";
$stmt = $pdoConn->prepare($sql);
$stmt->execute();
$result = $stmt->fetchAll();
?>

<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="white-box">
            <div class="row">
                <div class="col-md-6">
                    <h6>Link Url *</h6>
                    <div class="p-2">
                        <input type="text" class="form-control" id="linkurl" placeholder="Link Url" required>
                    </div>
                </div>

                <div class="col-md-6">
                    <h6>Link Name*</h6>
                    <div class="p-2">
                        <input type="text" class="form-control" id="linkname" placeholder="Link Name" required>
                    </div>
                </div>
            </div>
            <div class="text-end">
                <a class="btn btn-success text-white addLink">
                    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 32 32">
                        <path fill="currentColor" d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z" />
                    </svg>
                    Add New Link
                </a>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">All links</h3>
            </div>
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Title</th>
                            <th class="border-top-0">Link</th>
                            <th class="border-top-0">Date</th>
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
                                    echo $value['name'];
                                    ?>
                                </td>
                                <td>
                                    <a href="<?php echo $value['url']; ?>" target="_blank">
                                        <?php echo $value['url']; ?>
                                    </a>
                                </td>
                                <td><?php echo date('d M h:i A', strtotime($value['created_date'])); ?></td>
                                <td>
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
    $('.addLink').click(function() {
        var linkurl = $('#linkurl').val();
        var linkname = $('#linkname').val();
        if (linkurl == '' || linkname == '') {
            alert('Please fill all fields');
            return false;
        }
        $.ajax({
            url: "<?= $apiUrl ?>",
            type: 'POST',
            data: {
                linkurl: linkurl,
                linkname: linkname,
                mode: 'addlink'
            },
            success: function(data) {
                if (data.error.code == '#200') {
                    swal({
                        title: 'Success!',
                        icon: 'success',
                        text: "Link added successfully",
                        confirmButtonText: 'Ok'
                    }).then((result) => {
                     location.reload();
                    });
                }
            }
        });
    });

    function deleteCode($id) {
        $.ajax({
            url: "<?= $apiUrl ?>",
            type: 'POST',
            data: {
                linkid: $id,
                mode: 'deletelink'
            },
            success: function(data) {
                if (data.error.code == '#200') {
                    swal({
                        title: 'Success!',
                        icon: 'success',
                        text: "Link deleted successfully",
                        confirmButtonText: 'Ok'
                    }).then((result) => {
                        location.reload();
                    });
                }
            }
        });
    }
</script>