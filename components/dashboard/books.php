<?php
$category = isset($_GET['category']) ? $_GET['category'] : '';
?>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="white-box text-end">
            <a href="<?= $adminBaseUrl ?>addprofiles" class="btn btn-success text-white">
                <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 32 32">
                    <path fill="currentColor" d="M17 15V8h-2v7H8v2h7v7h2v-7h7v-2z" />
                </svg>
                Add new photo
            </a>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">All Photos</h3>
            </div>
            <div class="col-md-6">
                <?php
                $sql = "SELECT count(*) as total FROM `couplewallpapers`";
                $stmt = $conn->prepare($sql);
                $stmt->execute();
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                ?>
                <p><b>Total Photos: <?= $result['total'] ?></b></p>
            </div>
            <br />
            <div class="table-responsive">
                <table class="table no-wrap bDataTable" id="bDataTable">
                    <thead>
                        <tr>
                            <th class="border-top-0">#</th>
                            <th class="border-top-0">Title</th>
                            <th class="border-top-0">Views</th>
                            <th class="border-top-0">Created At</th>
                            <th class="border-top-0">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        $sql = "";
                        $sql = "SELECT * FROM `couplewallpapers`  ORDER BY `id` DESC ";
                        $stmt = $conn->prepare($sql);
                        $stmt->bindParam(':category1', $category);
                        $stmt->bindParam(':category2', $category);
                        $stmt->execute();
                        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

                        foreach ($result as $key => $value) {
                            echo '<tr> <td>' . ($key + 1) . '</td>';
                            echo '<td>' . $value['title'] . '</td>
                                    <td>' . $value['views'] . '</td>
                                    <td>' . $value['created_at'] . '</td>
                                    <td>
                                        <a href="' . $adminBaseUrl . 'editprofiles?bookid=' . $value['id'] . '" class="btn btn-primary text-white m-0">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"><path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a.996.996 0 0 0 0-1.41l-2.34-2.34a.996.996 0 0 0-1.41 0l-1.83 1.83l3.75 3.75l1.83-1.83z"/></svg>
                                            Edit
                                        </a>
                                        <button class="btn btn-danger text-white  m-0" onclick="deleteAdmin(' . $value['id'] . ')">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 32 32"><path fill="currentColor" d="M13.5 6.5V7h5v-.5a2.5 2.5 0 0 0-5 0Zm-2 .5v-.5a4.5 4.5 0 1 1 9 0V7H28a1 1 0 1 1 0 2h-1.508L24.6 25.568A5 5 0 0 1 19.63 30h-7.26a5 5 0 0 1-4.97-4.432L5.508 9H4a1 1 0 0 1 0-2h7.5ZM9.388 25.34a3 3 0 0 0 2.98 2.66h7.263a3 3 0 0 0 2.98-2.66L24.48 9H7.521l1.867 16.34ZM13 12.5a1 1 0 0 1 1 1v10a1 1 0 1 1-2 0v-10a1 1 0 0 1 1-1Zm7 1a1 1 0 1 0-2 0v10a1 1 0 1 0 2 0v-10Z"/></svg>
                                            Delete
                                        </button>
                                    </td>
                                </tr>';
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
        $("#medium").change(function() {
            var departmentid = $(this).val();
            window.location.href = "<?= $adminBaseUrl ?>profiles?category=" + departmentid;
        });
    });

    function deleteAdmin(id) {
        swal({
            title: 'Are you sure you want to delete this class ?',
            text: "The class will be deleted permanently!",
            icon: 'warning',
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                $.ajax({
                    url: "<?= (string)$apiUrl ?>",
                    type: 'POST',
                    data: {
                        mode: 'deletebooks',
                        medium: '<?= $medium ?>',
                        class: '<?= $class ?>',
                        id: id,
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