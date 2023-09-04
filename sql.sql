CREATE TABLE `categories` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `thumbnail` varchar(255) NOT NULL,
    `images_count` int(11) NOT NULL,
    `subcategories_count` int(11) NOT NULL,
    `created_at` datetime NOT NULL,
    `updated_at` datetime NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;

CREATE TABLE `subcategories` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `category_id` int(11) NOT NULL,
    `name` varchar(255) NOT NULL,
    `thumbnail` varchar(255) NOT NULL,
    `images_count` int(11) NOT NULL,
    `created_at` datetime NOT NULL,
    `updated_at` datetime NOT NULL,
    PRIMARY KEY (`id`),
    KEY `category_id` (`category_id`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;

CREATE TABLE `images` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `subcategory_id` int(11) NOT NULL,
    `category_id` int(11) NOT NULL,
    `name` varchar(255) NOT NULL,
    `thumbnail` varchar(255) NOT NULL,
    `views` int(11) NOT NULL,
    `likes` int(11) NOT NULL,
    `created_at` datetime NOT NULL,
    `updated_at` datetime NOT NULL,
    PRIMARY KEY (`id`),
    KEY `subcategory_id` (`subcategory_id`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;