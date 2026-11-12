# Allan - Atividades recentes

Tabela `webdriver.atividades_recentes`, da Parte 2.

| Campo | Tipo | Descrição |
|---|---|---|
| id_arquivo | BIGINT UNSIGNED | PK e FK para `arquivo.id_arquivo` |
| ultima_versao | DATE | data da última edição do arquivo |
| acesso | ENUM('PRIORITARIO', 'NAO_PRIORITARIO') | padrão NAO_PRIORITARIO |

A tabela começa vazia. Quem preenche é a procedure `Verificar_atividades`, que vem no segundo commit junto com a `Chavear`.

## Como rodar

Conectar como root no banco que já tem a Parte 1 e executar `sql/02-atividades-recentes.sql`. Depois conferir com:

```sql
DESCRIBE webdriver.atividades_recentes;
SHOW CREATE TABLE webdriver.atividades_recentes;
```

O script roda uma vez só. Se a tabela já existir, vai dar erro.

## Acesso só do root

O script não dá permissão a ninguém, mas isso não basta. Contas que já tenham privilégio em `webdriver.*` ou `*.*` continuam enxergando a tabela. Quem fizer as roles precisa dar permissão por tabela e por view, deixando `atividades_recentes` de fora, e evitar views ou rotinas com SQL SECURITY DEFINER que exponham essa tabela.

Depois que as roles estiverem prontas, testar: `SELECT` na tabela funciona no root e é negado para usuário, empresa e administrador da aplicação.

Referência: https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html
