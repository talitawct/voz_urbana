# Voz Urbana

Aplicativo Flutter para registro de problemas urbanos como buracos, falta de
iluminacao, lixo acumulado, esgoto e outras ocorrencias de infraestrutura.

## Recursos implementados

- Cadastro e login demonstrativos com validacoes minimas.
- Login rapido pelos botoes Google e Gov.br usando usuarios de teste.
- Captura de foto da denuncia com permissao de camera.
- Captura automatica da localizacao com permissao de GPS.
- Persistencia local das denuncias com SQLite.
- Historico de denuncias salvas.
- Mapa com Google Maps, localizacao atual e marcadores das denuncias salvas.
- Envio de e-mail demonstrativo para `talitawct3@gmail.com` via FormSubmit.
- Tema claro/escuro e tela de perfil basica.

## Usuario de teste

Login por e-mail:

- E-mail: `teste@vozurbana.com`
- Senha: `123456`

Os botoes "Entrar com Google" e "Entrar com Gov.br" fazem login automatico com
usuarios demonstrativos para apresentacao academica.

## Configuracao do Google Maps

Substitua `SUA_CHAVE_GOOGLE_MAPS_AQUI` por uma chave valida da Google Maps API:

- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/AppDelegate.swift`

Sem essa chave, a tela de mapa pode nao renderizar corretamente.

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

- Trocar a chave `SUA_CHAVE_GOOGLE_MAPS_AQUI` por uma chave real.
- Rodar `flutter pub get`.
- Rodar `flutter analyze`.
- Testar no dispositivo ou emulador com camera e localizacao habilitadas.
- Fazer uma primeira denuncia para ativar/confirmar o FormSubmit no e-mail de destino.
- Demonstrar o fluxo: login, foto, localizacao, categoria, envio, historico e mapa.
