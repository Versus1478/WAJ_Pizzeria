DROP DATABASE IF EXISTS pizzeria;
CREATE DATABASE pizzeria CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE pizzeria;

CREATE TABLE `user` (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    first_name  VARCHAR(128) NOT NULL,
    last_name   VARCHAR(128) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    password    VARCHAR(255) NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_email (email)
) ENGINE = InnoDB;

CREATE TABLE user_profile (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    user_id      BIGINT       NOT NULL,
    phone        VARCHAR(32)  NOT NULL,
    street       VARCHAR(255) NOT NULL,
    city         VARCHAR(128) NOT NULL,
    postal_code  VARCHAR(10)  NOT NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_profile_user (user_id),
    CONSTRAINT fk_user_profile_user FOREIGN KEY (user_id) REFERENCES `user` (id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE role (
    id    BIGINT      NOT NULL AUTO_INCREMENT,
    name  VARCHAR(64) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_role_name (name)
) ENGINE = InnoDB;

CREATE TABLE user_role (
    user_id  BIGINT NOT NULL,
    role_id  BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES `user` (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE pizza (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    name         VARCHAR(128) NOT NULL,
    slug         VARCHAR(192) NOT NULL,
    description  TEXT         NOT NULL,
    image_url    VARCHAR(512) NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at   TIMESTAMP    NULL DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_pizza_name (name),
    UNIQUE KEY uk_pizza_slug (slug)
) ENGINE = InnoDB;

CREATE TABLE pizza_size (
    id           BIGINT                          NOT NULL AUTO_INCREMENT,
    pizza_id     BIGINT                          NOT NULL,
    size         ENUM ('SMALL', 'MEDIUM', 'LARGE') NOT NULL,
    diameter_cm  SMALLINT                        NOT NULL,
    price        DECIMAL(10, 2)                  NOT NULL,
    created_at   TIMESTAMP                       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP                       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_pizza_size_pizza_size (pizza_id, size),
    CONSTRAINT fk_pizza_size_pizza FOREIGN KEY (pizza_id) REFERENCES pizza (id) ON DELETE CASCADE,
    CONSTRAINT chk_pizza_size_price CHECK (price > 0),
    CONSTRAINT chk_pizza_size_diameter CHECK (diameter_cm BETWEEN 15 AND 60)
) ENGINE = InnoDB;

CREATE TABLE ingredient (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    vegetarian  BOOLEAN      NOT NULL DEFAULT FALSE,
    vegan       BOOLEAN      NOT NULL DEFAULT FALSE,
    pizza_base  BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_ingredient_name (name),
    CONSTRAINT chk_ingredient_vegan CHECK (vegan = FALSE OR vegetarian = TRUE)
) ENGINE = InnoDB;

CREATE TABLE pizza_ingredient (
    pizza_id       BIGINT NOT NULL,
    ingredient_id  BIGINT NOT NULL,
    PRIMARY KEY (pizza_id, ingredient_id),
    CONSTRAINT fk_pizza_ingredient_pizza FOREIGN KEY (pizza_id) REFERENCES pizza (id) ON DELETE CASCADE,
    CONSTRAINT fk_pizza_ingredient_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredient (id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE tag (
    id          BIGINT      NOT NULL AUTO_INCREMENT,
    name        VARCHAR(64) NOT NULL,
    slug        VARCHAR(80) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tag_name (name),
    UNIQUE KEY uk_tag_slug (slug)
) ENGINE = InnoDB;

CREATE TABLE pizza_tag (
    pizza_id  BIGINT NOT NULL,
    tag_id    BIGINT NOT NULL,
    PRIMARY KEY (pizza_id, tag_id),
    CONSTRAINT fk_pizza_tag_pizza FOREIGN KEY (pizza_id) REFERENCES pizza (id) ON DELETE CASCADE,
    CONSTRAINT fk_pizza_tag_tag FOREIGN KEY (tag_id) REFERENCES tag (id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE cart (
    id          BIGINT    NOT NULL AUTO_INCREMENT,
    user_id     BIGINT    NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_cart_user (user_id),
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES `user` (id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE cart_item (
    id             BIGINT    NOT NULL AUTO_INCREMENT,
    cart_id        BIGINT    NOT NULL,
    pizza_size_id  BIGINT    NOT NULL,
    quantity       INT       NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_cart_item_cart_pizza_size (cart_id, pizza_size_id),
    CONSTRAINT fk_cart_item_cart FOREIGN KEY (cart_id) REFERENCES cart (id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_item_pizza_size FOREIGN KEY (pizza_size_id) REFERENCES pizza_size (id) ON DELETE CASCADE,
    CONSTRAINT chk_cart_item_quantity CHECK (quantity BETWEEN 1 AND 20)
) ENGINE = InnoDB;

CREATE TABLE orders (
    id                    BIGINT         NOT NULL AUTO_INCREMENT,
    customer_id           BIGINT         NOT NULL,
    cook_id               BIGINT         NULL,
    courier_id            BIGINT         NULL,
    status                ENUM ('NEW', 'IN_PREPARATION', 'READY', 'DELIVERING', 'DELIVERED', 'CANCELLED') NOT NULL DEFAULT 'NEW',
    customer_first_name   VARCHAR(128)   NOT NULL,
    customer_last_name    VARCHAR(128)   NOT NULL,
    customer_email        VARCHAR(255)   NOT NULL,
    customer_phone        VARCHAR(32)    NOT NULL,
    delivery_street       VARCHAR(255)   NOT NULL,
    delivery_city         VARCHAR(128)   NOT NULL,
    delivery_postal_code  VARCHAR(10)    NOT NULL,
    payment_method        ENUM ('CASH', 'CARD') NOT NULL DEFAULT 'CASH',
    note                  VARCHAR(500)   NULL,
    subtotal             DECIMAL(10, 2) NOT NULL,
    discount_amount       DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_price           DECIMAL(10, 2) NOT NULL,
    discount_code         VARCHAR(16)    NOT NULL,
    used_discount_code    VARCHAR(16)    NULL,
    created_at            TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_orders_discount_code (discount_code),
    UNIQUE KEY uk_orders_used_discount_code (used_discount_code),
    KEY idx_orders_status (status),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES `user` (id),
    CONSTRAINT fk_orders_cook FOREIGN KEY (cook_id) REFERENCES `user` (id),
    CONSTRAINT fk_orders_courier FOREIGN KEY (courier_id) REFERENCES `user` (id),
    CONSTRAINT chk_orders_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_orders_discount CHECK (discount_amount >= 0 AND discount_amount <= subtotal),
    CONSTRAINT chk_orders_total CHECK (total_price = subtotal - discount_amount)
) ENGINE = InnoDB;

CREATE TABLE order_item (
    id             BIGINT                            NOT NULL AUTO_INCREMENT,
    order_id       BIGINT                            NOT NULL,
    pizza_size_id  BIGINT                            NULL,
    pizza_name     VARCHAR(128)                      NOT NULL,
    size           ENUM ('SMALL', 'MEDIUM', 'LARGE') NOT NULL,
    diameter_cm    SMALLINT                          NOT NULL,
    unit_price     DECIMAL(10, 2)                    NOT NULL,
    quantity       INT                               NOT NULL,
    created_at     TIMESTAMP                         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_item_pizza_size FOREIGN KEY (pizza_size_id) REFERENCES pizza_size (id) ON DELETE SET NULL,
    CONSTRAINT chk_order_item_unit_price CHECK (unit_price > 0),
    CONSTRAINT chk_order_item_quantity CHECK (quantity BETWEEN 1 AND 20)
) ENGINE = InnoDB;

CREATE TABLE order_status_history (
    id             BIGINT    NOT NULL AUTO_INCREMENT,
    order_id       BIGINT    NOT NULL,
    changed_by_id  BIGINT    NULL,
    old_status     ENUM ('NEW', 'IN_PREPARATION', 'READY', 'DELIVERING', 'DELIVERED', 'CANCELLED') NULL,
    new_status     ENUM ('NEW', 'IN_PREPARATION', 'READY', 'DELIVERING', 'DELIVERED', 'CANCELLED') NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_order_status_history_order_created (order_id, created_at),
    CONSTRAINT fk_order_status_history_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_status_history_user FOREIGN KEY (changed_by_id) REFERENCES `user` (id) ON DELETE SET NULL
) ENGINE = InnoDB;
