DROP DATABASE IF EXISTS gallery;
CREATE DATABASE gallery;

\c gallery
SET search_path TO public;

DROP TABLE IF EXISTS user_imports;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS restaurants;

-- restaurants table
CREATE TABLE "restaurants" (
  "restaurant_id" SERIAL PRIMARY KEY,
  -- general restaurant info
  "restaurant_name" varchar(80) NOT NULL,
  "site_url" varchar(40),
  "phone_number" varchar(30),

  -- location info
  "city" varchar(40) NOT NULL,
  "street" varchar(40),
  "state_or_province" varchar(5),
  "country" varchar(5) NOT NULL,
  "zip" varchar(15)
);

-- users who uploaded photos
CREATE TABLE "users" (
  "user_id" SERIAL PRIMARY KEY,
  "user_url" varchar(40) NOT NULL, -- url of user's profile (potentially scale this down)
  "user_name" varchar(40) NOT NULL, -- user's full name (scale this down)
  "user_review_count" smallint DEFAULT 0, -- number of user's reviews
  "user_friend_count" smallint DEFAULT 0, -- number of user's friends
  "user_photo_count" smallint DEFAULT 0, -- number of user's photos
  "user_elite_status" boolean DEFAULT false, -- whether user is elite
  "user_profile_image" varchar(40)
);

-- photos table grouped by gallery id
CREATE TABLE "photos" (
  "photo_id" SERIAL PRIMARY KEY,
  "restaurant_id" int REFERENCES restaurants(restaurant_id) NOT NULL,
  "user_id" int REFERENCES users(user_id) NOT NULL,
  "helpful_count" int DEFAULT 0, -- helpful rating of photo
  "not_helpful_count" int DEFAULT 0, -- not helpful rating of photo
  "photo_url" varchar(20) NOT NULL, -- (potentially scale this down)
  "caption" text,
  "upload_date" varchar(30)
);

-- using an import table for users to skip inserting any conflicts
CREATE TABLE "user_imports" (
  "user_id" int,
  "user_url" varchar(150) NOT NULL, -- url of user's profile (potentially scale this down)
  "user_name" varchar(100) NOT NULL, -- user's full name (scale this down)
  "user_review_count" smallint DEFAULT 0, -- number of user's reviews
  "user_friend_count" smallint DEFAULT 0, -- number of user's friends
  "user_photo_count" smallint DEFAULT 0, -- number of user's photos
  "user_elite_status" boolean DEFAULT false, -- whether user is elite
  "user_profile_image" varchar(255)
);

-- restaurant info chunk #1
\copy restaurants(restaurant_id, restaurant_name, site_url, phone_number, city, street, state_or_province, country, zip) FROM '../generated/postgres/restaurants/restaurants_0.csv' CSV HEADER DELIMITER ',';

\copy user_imports(user_id, user_url, user_name, user_review_count, user_friend_count, user_photo_count, user_elite_status, user_profile_image) FROM '../generated/postgres/users/users_0.csv' CSV HEADER DELIMITER ',';

INSERT INTO users (SELECT * FROM user_imports) ON CONFLICT DO NOTHING;

TRUNCATE user_imports;

\copy photos(photo_id, restaurant_id, user_id, helpful_count, not_helpful_count, photo_url, caption, upload_date) FROM '../generated/postgres/photos/photos_0.csv' CSV HEADER DELIMITER ',';

-- restaurant info chunk #2
\copy restaurants(restaurant_id, restaurant_name, site_url, phone_number, city, street, state_or_province, country, zip) FROM '../generated/postgres/restaurants/restaurants_1.csv' CSV HEADER DELIMITER ',';

\copy user_imports(user_id, user_url, user_name, user_review_count, user_friend_count, user_photo_count, user_elite_status, user_profile_image) FROM '../generated/postgres/users/users_1.csv' CSV HEADER DELIMITER ',';

INSERT INTO users (SELECT * FROM user_imports) ON CONFLICT DO NOTHING;

TRUNCATE user_imports;

\copy photos(photo_id, restaurant_id, user_id, helpful_count, not_helpful_count, photo_url, caption, upload_date) FROM '../generated/postgres/photos/photos_1.csv' CSV HEADER DELIMITER ',';

-- restaurant info chunk #3
\copy restaurants(restaurant_id, restaurant_name, site_url, phone_number, city, street, state_or_province, country, zip) FROM '../generated/postgres/restaurants/restaurants_2.csv' CSV HEADER DELIMITER ',';

\copy user_imports(user_id, user_url, user_name, user_review_count, user_friend_count, user_photo_count, user_elite_status, user_profile_image) FROM '../generated/postgres/users/users_2.csv' CSV HEADER DELIMITER ',';

INSERT INTO users (SELECT * FROM user_imports) ON CONFLICT DO NOTHING;

TRUNCATE user_imports;

\copy photos(photo_id, restaurant_id, user_id, helpful_count, not_helpful_count, photo_url, caption, upload_date) FROM '../generated/postgres/photos/photos_2.csv' CSV HEADER DELIMITER ',';

-- restaurant info chunk #4
\copy restaurants(restaurant_id, restaurant_name, site_url, phone_number, city, street, state_or_province, country, zip) FROM '../generated/postgres/restaurants/restaurants_3.csv' CSV HEADER DELIMITER ',';

\copy user_imports(user_id, user_url, user_name, user_review_count, user_friend_count, user_photo_count, user_elite_status, user_profile_image) FROM '../generated/postgres/users/users_3.csv' CSV HEADER DELIMITER ',';

INSERT INTO users (SELECT * FROM user_imports) ON CONFLICT DO NOTHING;

TRUNCATE user_imports;

\copy photos(photo_id, restaurant_id, user_id, helpful_count, not_helpful_count, photo_url, caption, upload_date) FROM '../generated/postgres/photos/photos_3.csv' CSV HEADER DELIMITER ',';

-- restaurant info chunk #5
\copy restaurants(restaurant_id, restaurant_name, site_url, phone_number, city, street, state_or_province, country, zip) FROM '../generated/postgres/restaurants/restaurants_4.csv' CSV HEADER DELIMITER ',';

\copy user_imports(user_id, user_url, user_name, user_review_count, user_friend_count, user_photo_count, user_elite_status, user_profile_image) FROM '../generated/postgres/users/users_4.csv' CSV HEADER DELIMITER ',';

INSERT INTO users (SELECT * FROM user_imports) ON CONFLICT DO NOTHING;

TRUNCATE user_imports;

\copy photos(photo_id, restaurant_id, user_id, helpful_count, not_helpful_count, photo_url, caption, upload_date) FROM '../generated/postgres/photos/photos_4.csv' CSV HEADER DELIMITER ',';

DROP TABLE user_imports;

-- update restaurant_id sequence
SELECT setval(pg_get_serial_sequence('restaurants', 'restaurant_id'), coalesce(max(restaurant_id)+1, 1), false) FROM restaurants;

-- update user_id sequence
SELECT setval(pg_get_serial_sequence('users', 'user_id'), coalesce(max(user_id)+1, 1), false) FROM users;

-- update photo_id sequence
SELECT setval(pg_get_serial_sequence('photos', 'photo_id'), coalesce(max(photo_id)+1, 1), false) FROM photos;

 -- add indices
CREATE INDEX idx_restaurant_name ON restaurants(restaurant_name);
CREATE INDEX idx_user_name ON users(user_name);
CREATE INDEX idx_restaurant_id ON photos(restaurant_id);
CREATE INDEX idx_user_id ON photos(user_id);