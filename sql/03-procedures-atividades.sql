USE webdriver;
DELIMITER $$

CREATE PROCEDURE Verificar_atividades(IN p_id_arquivo BIGINT UNSIGNED)
SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
    DECLARE v_id BIGINT UNSIGNED DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_id = NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_id_arquivo IS NULL OR p_id_arquivo = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Informe um ID de arquivo positivo';
    END IF;

    START TRANSACTION;
    SELECT id_arquivo INTO v_id
    FROM arquivo
    WHERE id_arquivo = p_id_arquivo AND excluido_em IS NULL
    FOR UPDATE;

    IF v_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Arquivo inexistente ou removido';
    END IF;

    INSERT INTO atividades_recentes (id_arquivo, ultima_versao)
    VALUES (p_id_arquivo, CURRENT_DATE())
    ON DUPLICATE KEY UPDATE ultima_versao = CURRENT_DATE();

    COMMIT;
END$$

CREATE PROCEDURE Chavear(IN p_id_arquivo BIGINT UNSIGNED)
SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
    IF p_id_arquivo IS NULL OR p_id_arquivo = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Informe um ID de arquivo positivo';
    END IF;

    UPDATE atividades_recentes ar
    INNER JOIN arquivo a ON a.id_arquivo = ar.id_arquivo
    SET ar.acesso = CASE ar.acesso
        WHEN 'PRIORITARIO' THEN 'NAO_PRIORITARIO'
        ELSE 'PRIORITARIO'
    END
    WHERE ar.id_arquivo = p_id_arquivo AND a.excluido_em IS NULL;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Arquivo ativo sem registro de atividade, inexistente ou removido';
    END IF;
END$$

DELIMITER ;
