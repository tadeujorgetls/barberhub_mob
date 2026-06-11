# Supabase setup

## 1. Criar projeto

Crie um projeto no Supabase e copie:

- Project URL
- anon public key

## 2. Rodar a migration

No SQL Editor do Supabase, execute o arquivo:

```sql
supabase/migrations/20260609133000_initial_auth_profiles.sql
```

Essa migration cria a tabela `profiles`, ativa RLS e liga um trigger ao
`auth.users` para criar o perfil automaticamente depois do cadastro.

## 3. Rodar o app com Supabase

Use `--dart-define` para passar as credenciais sem commitar chave no Git:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

No Windows PowerShell:

```powershell
flutter run -d ZF5239KH9B `
  --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

Sem essas variaveis, o app continua usando o mock local para facilitar
desenvolvimento enquanto o backend ainda esta sendo configurado.

## Status da migracao

- Autenticacao: preparada para Supabase Auth.
- Perfil do usuario: tabela `profiles` criada via migration.
- Catalogo: barbearias, servicos, barbeiros e produtos carregam do Supabase quando configurado.`r`n- Agendamentos: criacao, listagem, cancelamento e remarcacao usam Supabase quando configurado.`r`n- Sem `--dart-define`, o app continua usando mock/local para desenvolvimento.
