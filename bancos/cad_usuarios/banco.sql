-- =============================================
-- Safe Walk - Script de criação do banco MySQL
-- Execute no MySQL Workbench ou via terminal:
-- mysql -u root -p < banco.sql
-- =============================================

CREATE DATABASE IF NOT EXISTS safewalk
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE safewalk;

CREATE TABLE IF NOT EXISTS usuarios (
  id           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  email        VARCHAR(180)    NOT NULL,
  senha_hash   VARCHAR(255)    NOT NULL,          -- bcrypt hash, NUNCA texto puro
  criado_em    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_email (email)
) ENGINE=InnoDB;
