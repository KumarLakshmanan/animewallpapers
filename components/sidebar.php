<header class="topbar" data-navbarbg="skin5" style="position:fixed;width: 100%">
    <nav class="navbar top-navbar navbar-expand-md navbar-dark">
        <div class="navbar-header" data-logobg="skin6">
            <a class="navbar-brand" href="<?= $baseUrl ?>" target="_blank">
                <b class="logo-icon">
                    <img src="<?= $baseUrl ?>img/icon-black.png" alt="homepage" style="height: 40px;">
                </b>
                <span class="logo-text">
                    <img src="<?= $baseUrl ?>img/text-black.png" alt="homepage" style="height: 30px;width: 150px;">
                </span>
            </a>
            <a class="nav-toggler waves-effect waves-light text-dark d-block d-md-none" href="javascript:void(0)"><i class="ti-menu ti-close"></i></a>
        </div>
        <ul class="navbar-nav ms-auto d-flex align-items-center px-2">
            <li>
                <a class="profile-pic" href="#">
                    <img src="<?= $baseUrl ?>img/varun.png" alt="user-img" width="36" class="img-circle"><span class="text-white font-medium">
                        <?php
                        if (isset($_SESSION['fullname'])) {
                            echo $_SESSION['fullname'];
                        } else {
                            echo "Guest";
                        }
                        ?>
                    </span></a>
            </li>
        </ul>
    </nav>
</header>
<aside class="left-sidebar" style="position:fixed" data-sidebarbg="skin6">
    <div class="scroll-sidebar" style="overflow-y: auto">
        <nav class="sidebar-nav">
            <ul id="sidebarnav">
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link"></a>
                    <a class="sidebar-link waves-effect waves-dark sidebar-link"></a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24">
                            <path fill="currentColor" d="M12.71 2.29a1 1 0 0 0-1.42 0l-9 9a1 1 0 0 0 0 1.42A1 1 0 0 0 3 13h1v7a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-7h1a1 1 0 0 0 1-1a1 1 0 0 0-.29-.71zM6 20v-9.59l6-6l6 6V20z" />
                        </svg>
                        <span class="hide-menu px-2">Home</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>quicklinks" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24">
                            <path fill="currentColor" d="M7 17q-2.075 0-3.537-1.463Q2 14.075 2 12t1.463-3.538Q4.925 7 7 7h3q.425 0 .713.287Q11 7.575 11 8t-.287.712Q10.425 9 10 9H7q-1.25 0-2.125.875T4 12q0 1.25.875 2.125T7 15h3q.425 0 .713.287q.287.288.287.713t-.287.712Q10.425 17 10 17Zm2-4q-.425 0-.712-.288Q8 12.425 8 12t.288-.713Q8.575 11 9 11h6q.425 0 .713.287q.287.288.287.713t-.287.712Q15.425 13 15 13Zm5 4q-.425 0-.712-.288Q13 16.425 13 16t.288-.713Q13.575 15 14 15h3q1.25 0 2.125-.875T20 12q0-1.25-.875-2.125T17 9h-3q-.425 0-.712-.288Q13 8.425 13 8t.288-.713Q13.575 7 14 7h3q2.075 0 3.538 1.462Q22 9.925 22 12q0 2.075-1.462 3.537Q19.075 17 17 17Z" />
                        </svg>
                        <span class="hide-menu px-2">Quick Links</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>announcements" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 20 20">
                            <path fill="currentColor" d="M3 6c0-1.1.9-2 2-2h8l4-4h2v16h-2l-4-4H5a2 2 0 0 1-2-2H1V6h2zm8 9v5H8l-1.67-5H5v-2h8v2h-2z" />
                        </svg>
                        <span class="hide-menu px-2">Announcements</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>notification" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24">
                            <path fill="currentColor" d="M12 22a2 2 0 0 1-2-2h4a2 2 0 0 1-2 2Zm8-3H4v-2l2-1v-5.5c0-3.462 1.421-5.707 4-6.32V2h4v2.18c2.579.612 4 2.856 4 6.32V16l2 1v2ZM12 5.75A3.6 3.6 0 0 0 8.875 7.2A5.692 5.692 0 0 0 8 10.5V17h8v-6.5a5.693 5.693 0 0 0-.875-3.3A3.6 3.6 0 0 0 12 5.75Z" />
                        </svg>
                        <span class="hide-menu px-2">Notification</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>messages" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24">
                            <path fill="currentColor" d="M21 2H6a2 2 0 0 0-2 2v3H2v2h2v2H2v2h2v2H2v2h2v3a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1zm-8 2.999c1.648 0 3 1.351 3 3A3.012 3.012 0 0 1 13 11c-1.647 0-3-1.353-3-3.001c0-1.649 1.353-3 3-3zM19 18H7v-.75c0-2.219 2.705-4.5 6-4.5s6 2.281 6 4.5V18z" />
                        </svg>
                        <span class="hide-menu px-2">Messages</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>categories" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
                            <path fill="currentColor" d="m12 2l-5.5 9h11z" />
                            <circle cx="17.5" cy="17.5" r="4.5" fill="currentColor" />
                            <path fill="currentColor" d="M3 13.5h8v8H3z" />
                        </svg>
                        <span class="hide-menu px-2">Categories</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>subcategories" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
                            <path fill="currentColor" d="m12 2l-5.5 9h11z" />
                            <circle cx="17.5" cy="17.5" r="4.5" fill="currentColor" />
                            <path fill="currentColor" d="M3 13.5h8v8H3z" />
                        </svg>
                        <span class="hide-menu px-2">Sub Categories</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>images" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
                            <path fill="currentColor" d="M2.992 21A.993.993 0 0 1 2 20.007V3.993A1 1 0 0 1 2.992 3h18.016c.548 0 .992.445.992.993v16.014a1 1 0 0 1-.992.993H2.992ZM20 15V5H4v14L14 9l6 6Zm0 2.828l-6-6L6.828 19H20v-1.172ZM8 11a2 2 0 1 1 0-4a2 2 0 0 1 0 4Z" />
                        </svg>
                        <span class="hide-menu px-2">Images</span>
                    </a>
                </li>
                <li class="sidebar-item">
                    <a class="sidebar-link waves-effect waves-dark sidebar-link" href="<?= $adminBaseUrl ?>logout" aria-expanded="false">
                        <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 256 256">
                            <path fill="currentColor" d="m224.5 136.5l-42 42a12 12 0 0 1-8.5 3.5a12.2 12.2 0 0 1-8.5-3.5a12 12 0 0 1 0-17L187 140h-83a12 12 0 0 1 0-24h83l-21.5-21.5a12 12 0 0 1 17-17l42 42a12 12 0 0 1 0 17ZM104 204H52V52h52a12 12 0 0 0 0-24H48a20.1 20.1 0 0 0-20 20v160a20.1 20.1 0 0 0 20 20h56a12 12 0 0 0 0-24Z" />
                        </svg>
                        <span class="hide-menu px-2">Logout</span>
                    </a>
                </li>
            </ul>
        </nav>
    </div>
</aside>