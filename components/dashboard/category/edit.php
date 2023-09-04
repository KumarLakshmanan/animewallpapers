<?php


if (isset($_GET['categoryid'])) {
    $id = $_GET['categoryid'];
    $sql = "SELECT * FROM categories WHERE id = :id";
    $stmt = $pdoConn->prepare($sql);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    $propertyEdit = $stmt->fetchAll();
    if (count($propertyEdit) > 0) {
?>
        <h3><b>Fill the Following Form To Add Job</b></h3>
        <br />
        <div class="row">
            <div class="col-md-6">
                <h6>Category Name *</h6>
                <div class="p-2">
                    <input type="text" class="form-control" id="title" placeholder="Enter Job name" required value="<?php echo $propertyEdit[0]['name']; ?>">
                </div>
            </div>
            <div class="col-12">
                <h6>Category Description *</h6>
                <div class="p-2">
                    <textarea rows="5" class="form-control texteditor-content" id="description" placeholder="Enter Job description" required><?php echo $propertyEdit[0]['description']; ?></textarea>
                </div>
            </div>
            <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
                <div class="p-2">
                    <label for="images">Category Image</label>
                    <div class="input-images" id="images" style="padding-top: .5rem;background: white"></div>
                </div>
            </div>
        </div>
        <div class="p-2">
            <button type="button" class="w-100 btn btn-primary saveButton">Save changes</button>
        </div>

        <link href="<?= $baseUrl ?>css/image-uploader.min.css" rel="stylesheet" />
        <script src="<?= $baseUrl ?>js/image-uploader.min.js"></script>
        <script>
            $(document).ready(() => {
                imageUploader.init(".input-images");
            })
            let _xUserData = {
                "baseURL": "<?= $baseUrl ?>",
                "auth": "<?= $_SESSION['token'] ?>",
                "username": "<?= $_SESSION['email'] ?>",
                "alreadyUploaded": "<?php echo ($propertyEdit[0]['thumbnail']); ?>",
            };
            $(".saveButton").click(function() {
                var name = $("#name").val();
                var images = [];
                $(".uploaded-image").each(function() {
                    images.push($(this).attr("data-name"));
                });
                var description = $("#description").val();
                var title = $("#title").val();
                var link = $("#link").val();

                if (images.length == 0) {
                    swal({
                        icon: 'error',
                        type: 'error',
                        title: 'Oops...',
                        text: 'Please upload at least one image!',
                    })
                } else if (title == "") {
                    swal({
                        icon: 'error',
                        type: 'error',
                        title: 'Oops...',
                        text: 'Please fill all required the fields!',
                    })
                } else {
                    swal({
                        title: 'Are you sure to publish?',
                        text: "The Job will be saved to the server!",
                        icon: 'warning',
                        buttons: true,
                        dangerMode: true,
                    }).then((willDelete) => {
                        if (willDelete) {
                            var formData = new FormData();
                            formData.append("mode", "editCategory");
                            formData.append("title", title);
                            formData.append("description", description);
                            formData.append("image", images[0]);
                            formData.append("categoryid", "<?= $id ?>");
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
                                            text: "Category updated successfully",
                                            confirmButtonText: 'Ok'
                                        }).then((result) => {
                                            window.location.reload();
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


            function deletePdf(id) {
                swal({
                    title: 'Are you sure you want to delete this pdf ?',
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
                                mode: 'deletepdf',
                                categoryid: id,
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
<?php
    }
}
