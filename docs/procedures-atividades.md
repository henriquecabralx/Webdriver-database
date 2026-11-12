# Allan - Procedures de atividades recentes

Duas procedures para a tabela `atividades_recentes`:

| Procedure | Parâmetro | O que faz |
|---|---|---|
| Verificar_atividades | p_id_arquivo | Grava a data de hoje em `ultima_versao`. Se o arquivo ainda não tem registro, cria um com a prioridade padrão (NAO_PRIORITARIO). Se já tem, mantém a prioridade. |
| Chavear | p_id_arquivo | Troca entre PRIORITARIO e NAO_PRIORITARIO, sem mexer em `ultima_versao`. |

O enunciado não diz a assinatura das procedures, então cada uma recebe o ID de um arquivo. Também não define prazo para classificar prioridade, então isso não é feito automático.

A `Verificar_atividades` deve ser chamada depois que o arquivo é editado, e não numa simples consulta, senão `ultima_versao` perde o sentido.

## Como rodar

Precisa do `sql/01-modelo-fisico.sql` e do `sql/02-atividades-recentes.sql` já executados. No Workbench, conectado como root, executar `sql/03-procedures-atividades.sql`. O script cria as duas procedures uma vez, então não rode de novo sem apagá-las antes.

A `Verificar_atividades` abre e fecha a própria transação, então não chame com outra transação aberta. A `Chavear` segue o autocommit da sessão: se ele estiver desligado, dê `COMMIT` depois.

Elas ainda não são chamadas pelo CRUD em Python.

## Testes

Com um arquivo de teste ativo (troque o 1 pelo ID real):

```sql
USE webdriver;
CALL Verificar_atividades(1);
SELECT * FROM atividades_recentes WHERE id_arquivo = 1;
```

`ultima_versao` deve ser a data de hoje e, na primeira vez, `acesso` deve ser NAO_PRIORITARIO.

```sql
CALL Chavear(1);
SELECT acesso FROM atividades_recentes WHERE id_arquivo = 1;
CALL Chavear(1);
SELECT acesso FROM atividades_recentes WHERE id_arquivo = 1;
```

O valor deve trocar e depois voltar ao original, sem mudar `ultima_versao`.

Outros casos:

- Colocar o arquivo como PRIORITARIO e chamar `Verificar_atividades` de novo: a prioridade deve continuar.
- Chamar duas vezes no mesmo dia: continua só uma linha por arquivo.
- Chamar com NULL, 0, ID que não existe ou arquivo removido: deve dar erro.
- Chamar `Chavear` num arquivo sem registro em `atividades_recentes`: deve dar erro. Rode antes a `Verificar_atividades`.

## Permissões

As duas usam `SQL SECURITY INVOKER`, ou seja, rodam com as permissões de quem chama e não com as do criador. Nenhum EXECUTE é dado a ninguém aqui. Quem montar as roles precisa deixar a tabela e as procedures fora dos GRANTs das contas da aplicação (usuário, empresa e administrador).
