<?php
if (!isset($conn)) {
    $path = $_SERVER['DOCUMENT_ROOT'];
    include($path . "/api/config.php");
    $db = new Connection();
    $conn = $db->getConnection();
}
$bookid = "";
if (isset($_GET['bookid'])) {
    $bookid = $_GET['bookid'];
    $sql = "SELECT * FROM `couplewallpapers` WHERE id = :bookid";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':bookid', $bookid);
    $stmt->execute();
    $propertyEdit = $stmt->fetchAll();
}
?>
<div class="row">
    <div class="col-md-12 col-lg-12 col-sm-12">
        <div class="white-box">
            <div class="d-md-flex mb-3">
                <h3 class="box-title mb-0">Fill the Following Form To Add Profile</h3>
            </div>
            <br />
            <div class="row">
                <div class="col-12">
                    <label>Title</label>
                    <div class="p-2">
                        <input type="text" class="form-control w-100" id="name" placeholder="Enter Title" required value="<?= $bookid != "" ? $propertyEdit[0]['title'] : "" ?>">
                    </div>
                </div>
                <br />
                <div class="col-6">
                    <label>Category</label>
                    <div class="p-2">
                        <input type="text" class="form-control w-100" id="category" placeholder="Enter Category" required value="<?= $bookid != "" ? $propertyEdit[0]['category'] : "" ?>" list="categoryList">
                    </div>
                </div>
                <div class="col-6">
                    <label>Status</label>
                    <div class="p-2">
                        <select class="form-control w-100" id="subcategory">
                            <option value="public" <?= $bookid != "" ? $propertyEdit[0]['subcategory'] : "" ?>>public</option>
                            <option value="premium" <?= $bookid != "" ? $propertyEdit[0]['subcategory'] : "" ?>>premium</option>
                            <option value="private" <?= $bookid != "" ? $propertyEdit[0]['subcategory'] : "" ?>>private</option>
                        </select>
                    </div>
                </div>
            </div>
            <datalist id="categoryList">
                <?php
                $sql = "SELECT category FROM `couplewallpapers` GROUP BY `category`";
                $stmt = $conn->prepare($sql);
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                foreach ($result as $key => $value) {
                    echo '<option value="' . $value['category'] . '" ' . ($medium == $value['category'] ? "selected" : "") . '>' . $value['category'] . '</option>';
                }
                ?>
            </datalist>
            <br />
            <div class="row">
                <div class="col-6">
                    <label>Image File 1</label>
                    <?php
                    if ($bookid != "") {
                    ?>
                        <img src="<?= $baseUrl ?>uploads/images/<?= $propertyEdit[0]['image1'] ?>" width="100px" height="100px" />
                    <?php
                    } ?>
                    <div class="p-2">
                        <input type="file" class="form-control w-100" id="image1" placeholder="Enter Image" required accept="images/*" />
                    </div>
                </div>
                <div class="col-6">
                    <label>Image File 2</label>
                    <?php
                    if ($bookid != "") {
                    ?>
                        <img src="<?= $baseUrl ?>uploads/images/<?= $propertyEdit[0]['image2'] ?>" width="100px" height="100px" />
                    <?php
                    } ?>
                    <div class="p-2">
                        <input type="file" class="form-control w-100" id="image2" placeholder="Enter Image" required accept="images/*" />
                    </div>
                </div>
            </div>
            <?php
            if ($bookid != "") {
            ?>
                <p>If you upload a new file, the old file will be replaced. otherwise, the old file will be used.</p>
            <?php
            } ?>
        </div>
    </div>
    <div class="p-2">
        <button type="button" class="w-100 btn btn-primary saveButton">Save changes</button>
    </div>
</div>
<link href="<?= $adminBaseUrl ?>css/image-uploader.min.css" rel="stylesheet" />
<script src="<?= $adminBaseUrl ?>js/image-uploader.min.js"></script>
<script>
    $(document).ready(() => {
        imageUploader.init(".input-images");
    })
    let _xUserData = {
        "baseURL": "<?= $baseUrl ?>",
        "auth": "<?= $_SESSION['token'] ?>",
        "username": "<?= $_SESSION['username'] ?>",
        "alreadyUploaded": "<?php echo ($propertyEdit[0]['images']); ?>",
    };
    if ($(".texteditor-content").length > 0) {
        $(".texteditor-content").richText();
    }

    $(".saveButton").click(function() {
        var bookname = $("#name").val();
        var category = $("#category").val();
        var bookid = "<?= $bookid ?>";
        var subcategory = $("#subcategory").val();
        if (bookname == "" || category == "" || subcategory == "") {
            console.table(bookname, category, classs, term);
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please fill all the fields!',
            })
        } else if ($("#image1")[0].files.length == 0 || $("#image2")[0].files.length == 0) {
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please upload images!',
            });
        } else {
            var image1 = $("#image1")[0].files[0];
            var image2 = $("#image2")[0].files[0];
            swal({
                title: 'Are you sure to save changes?',
                text: "The post will be updated and you won't be able to revert this!",
                icon: 'warning',
                buttons: true,
                dangerMode: true,
            }).then((willDelete) => {
                if (willDelete) {
                    var formData = new FormData();
                    formData.append("mode", "<?= $bookid != "" ? "editbooks" : "addbooks" ?>");
                    formData.append("bookname", bookname);
                    formData.append("category", category);
                    formData.append("image1", image1);
                    formData.append("image2", image2);
                    <?php
                    if ($bookid != "") {
                    ?>
                        formData.append("bookid", bookid);
                    <?php
                    }
                    ?>
                    $(".preloader").show();
                    $.ajax({
                        url: "<?= $apiUrl ?>",
                        type: "POST",
                        data: formData,
                        contentType: false,
                        cache: false,
                        processData: false,
                        success: function(response) {
                            $(".preloader").hide();
                            if (response.error.code == '#200') {
                                swal({
                                    title: 'Success!',
                                    icon: 'success',
                                    text: "This book updated successfully!",
                                    confirmButtonText: 'Ok'
                                }).then((result) => {
                                    if (result.value) {
                                        window.location.reload();
                                    }
                                });
                            } else {
                                swal({
                                    title: 'Error!',
                                    text: response.error.description,
                                    icon: 'error',
                                    confirmButtonText: 'Try Again'
                                })
                            }
                        }
                    });
                }
            });
        }
    });
</script>

<style>
    #keywordsInput {
        width: 100%;
        float: left;
    }

    #keywordsInput>input {
        padding: 7px;
        width: calc(100%);
    }
</style>