<?php

$pageId = "index";
if (isset($_GET["id"])) {
    $pageId = $_GET["id"];
}
?>
<!DOCTYPE html>
<html dir="ltr" lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.0/css/all.min.css" type="text/css">
    <link rel="stylesheet" href="<?= $baseUrl ?>css/richtext.min.css" type="text/css">
    <link rel="stylesheet" href="<?= $baseUrl ?>css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="<?= $baseUrl ?>css/dashboard.css" type="text/css" />
    <link rel="stylesheet" href="<?= $baseUrl ?>css/dataTables.bootstrap4.min.css">
    <script src="<?= $baseUrl ?>js/jquery.min.js"></script>
    <script src="<?= $baseUrl ?>js/sweetalert.js"></script>
    <script src="<?= $baseUrl ?>js/jquery.dataTables.min.js"></script>
    <script src="<?= $baseUrl ?>js/dataTables.bootstrap4.min.js"></script>
    <script src="<?= $baseUrl ?>js/bootstrap.min.js"></script>
    <script src="<?= $baseUrl ?>js/jquery.richtext.min.js"></script>
    <script src="<?= $baseUrl ?>js/custom.js"></script>
</head>

<body>
    <div class="preloader">
        <div class="lds-ripple">
            <div class="lds-pos"></div>
            <div class="lds-pos"></div>
        </div>
    </div>
    <div id="main-wrapper" data-layout="vertical" data-navbarbg="skin5" data-sidebartype="full" data-sidebar-position="absolute" data-header-position="absolute" data-boxed-layout="full">
        <?php include "./components/sidebar.php"; ?>
        <div class="page-wrapper mt-5">
            <div class="container-fluid">
                <?php
                if ($pageId == "courses") {
                    include "dashboard/courses.php";
                } else if ($pageId == "events") {
                    include "dashboard/events.php";
                } else if ($pageId == "slider") {
                    include "dashboard/slider.php";
                } elseif ($pageId == "editevent") {
                    include "dashboard/event/edit.php";
                } elseif ($pageId == "addevent") {
                    include "dashboard/event/add.php";
                } elseif ($pageId == "users") {
                    include "dashboard/users.php";
                } elseif ($pageId == "admins") {
                    include "dashboard/admins.php";
                } elseif ($pageId == "editadmin") {
                    include "dashboard/admin/edit.php";
                } else if ($pageId == "editadminabout") {
                    include "dashboard/admin/about.php";
                } else if ($pageId == "editadminsocial") {
                    include "dashboard/admin/social.php";
                } else if ($pageId == "editadminstaff") {
                    include "dashboard/admin/staff.php";
                } elseif ($pageId == "addadmin") {
                    include "dashboard/admin/add.php";
                } elseif ($pageId == "staffs") {
                    include "dashboard/staffs.php";
                } elseif ($pageId == "editstaff") {
                    include "dashboard/staff/edit.php";
                } elseif ($pageId == "addstaff") {
                    include "dashboard/staff/add.php";
                } elseif ($pageId == "messages") {
                    include "dashboard/messages.php";
                } elseif ($pageId == "notification") {
                    include "dashboard/notification.php";
                } else if ($pageId == "quicklinks") {
                    include "dashboard/quicklinks.php";
                } else if ($pageId == "announcements") {
                    include "dashboard/announcements.php";
                } else if ($pageId == 'contents') {
                    include "dashboard/contents.php";
                } else if ($pageId == 'facilities') {
                    include "dashboard/contents.php";
                } else if ($pageId == 'addcontent') {
                    include "dashboard/content/add.php";
                } else if ($pageId == 'editcontent') {
                    include "dashboard/content/edit.php";
                } else if ($pageId == 'addannouncement') {
                    include "dashboard/announcements/add.php";
                } else if ($pageId == 'editannouncement') {
                    include "dashboard/announcements/edit.php";
                } else if ($pageId == "news") {
                    include "dashboard/news.php";
                } else if ($pageId == 'addnews') {
                    include "dashboard/news/add.php";
                } else if ($pageId == 'editnews') {
                    include "dashboard/news/edit.php";
                } else if ($pageId == "gallery") {
                    include "dashboard/gallery.php";
                } else if ($pageId == 'addgallery') {
                    include "dashboard/gallery/add.php";
                } else if ($pageId == 'editgallery') {
                    include "dashboard/gallery/edit.php";
                } else if ($pageId == 'guest') {
                    include "dashboard/guest.php";
                } else if ($pageId == 'jobs') {
                    include "dashboard/jobs.php";
                } else if ($pageId == 'addjobs') {
                    include "dashboard/jobs/add.php";
                } else if ($pageId == 'editjobs') {
                    include "dashboard/jobs/edit.php";
                } else {
                    include "dashboard/home.php";
                }
                ?>
            </div>
            <footer class="footer text-center"> Created by <a href="https://kumarlakshmanan.github.io">Lakshmanan</a></footer>
        </div>
    </div>
</body>

</html>