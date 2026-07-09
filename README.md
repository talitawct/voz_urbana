# Voz Urbana

Aplicativo Flutter para registro de problemas urbanos como buracos, falta de
iluminacao, lixo acumulado, esgoto e outras ocorrencias de infraestrutura.

## Recursos implementados

- Cadastro e login demonstrativos com validacoes minimas.
- Login rapido pelos botoes Google e Gov.br usando usuarios de teste.
- Captura de foto da denuncia com permissao de camera.
- Captura automatica da localizacao com permissao de GPS.
- Persistencia local das denuncias com SQLite.
- Historico de denuncias salvas com detalhes, protocolo, status e exclusao.
- Mapa com OpenStreetMap, localizacao atual e marcadores das denuncias salvas.
- Alteracao de status entre pendente e resolvido.
- Envio de e-mail demonstrativo para `talitawct3@gmail.com` via FormSubmit com protocolo.
- Tema claro/escuro e tela de perfil basica.

## Usuario de teste

Login por e-mail:

- E-mail: `teste@vozurbana.com`
- Senha: `123456`

Os botoes "Entrar com Google" e "Entrar com Gov.br" fazem login automatico com
usuarios demonstrativos para apresentacao academica.

## Mapa com OpenStreetMap

O mapa usa OpenStreetMap via `flutter_map`, sem necessidade de chave da Google.
Para carregar os tiles, o dispositivo precisa estar conectado a internet.

## Observacao sobre envio de e-mail

O envio usa FormSubmit para manter o projeto simples e sem backend. No primeiro
envio, o destinatario pode precisar confirmar a ativacao recebida por e-mail.

## Execucao

```bash
flutter pub get
flutter run
```

No ambiente atual, a instalacao local do Flutter via Snap pode bloquear comandos
com erro de AppArmor. Nesse caso, use uma instalacao Flutter fora do Snap ou
habilite corretamente o servico `snapd.apparmor`.

## Checklist para apresentacao

- Rodar `flutter pub get`.
- Rodar `flutter analyze`.
- Confirmar conexao com internet para carregar o mapa OpenStreetMap.
- Testar no dispositivo ou emulador com camera e localizacao habilitadas.
- Fazer uma primeira denuncia para ativar/confirmar o FormSubmit no e-mail de destino.
- Demonstrar o fluxo: login, foto, localizacao, categoria, envio, protocolo, historico, status e mapa.
