-- Creates an initial user called 'admin'
-- with a password hash that was generated using the 'generate_password_hash.sql' page.
INSERT INTO user_info (username, activation, nom, prenom, groupe)
VALUES ('api_admin', '54321', 'Soulié', 'David',3);
