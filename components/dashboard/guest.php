<?php

$sql = "SELECT regid, device, created_at, ip, COUNT(*) as count FROM guests GROUP BY regid ORDER BY id DESC";
$stmt = $pdoConn->prepare($sql);
$stmt->execute();
$result = $stmt->fetchAll();
?>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">All Guest Users</h3>
            </div>
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Device Brand</th>
                            <th class="border-top-0">Device model</th>
                            <th class="border-top-0">Device Ratio</th>
                            <th class="border-top-0">IP Address</th>
                            <th class="border-top-0">No. Of Visits</th>
                            <th class="border-top-0">First Seen</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        foreach ($result as $key => $value) {
                            $device = json_decode($value['device'], true);
                        ?>
                            <tr>
                                <td><?php echo $key + 1; ?></td>
                                <td>
                                    <?php
                                    echo strtoupper($device['brand']);
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    echo $device['model'];
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    // echo $device['width'] . ' x ' . $device['height'];
                                    // round to 2 decimal places
                                    echo round($device['width'], 2) . ' x ' . round($device['height'], 2);
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    echo $value['ip'];
                                    ?>
                                </td>
                                <td>
                                    <?php
                                    echo $value['count'];
                                    ?>
                                </td>
                                <td><?php echo date('d M h:i A', strtotime($value['created_at'])); ?></td>
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
                eventid: $id,
                mode: 'deletenews'
            },
            success: function(data) {
                if (data.error.code == '#200') {
                    swal({
                        title: 'Success!',
                        icon: 'success',
                        text: "News deleted successfully",
                        confirmButtonText: 'Ok'
                    }).then((result) => {
                        location.reload();
                    });
                }
            }
        });
    }
</script>