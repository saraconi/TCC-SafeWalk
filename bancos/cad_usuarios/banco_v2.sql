-- =============================================
-- Safe Walk - Atualização do banco (v2)
-- Execute no MySQL Workbench após o banco.sql
-- =============================================

USE safewalk;

-- Tabela de contatos de emergência
CREATE TABLE IF NOT EXISTS contatos (
  id           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  usuario_id   INT UNSIGNED  NOT NULL,
  nome         VARCHAR(120)  NOT NULL,
  telefone     VARCHAR(20)   NOT NULL,
  criado_em    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabela de áudios gravados
CREATE TABLE IF NOT EXISTS audios (
  id           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  usuario_id   INT UNSIGNED  NOT NULL,
  nome         VARCHAR(120)  NOT NULL,
  duracao      VARCHAR(10)   NOT NULL DEFAULT '00:00',
  arquivo      VARCHAR(255)  NOT NULL,           -- nome do arquivo no servidor
  criado_em    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;
