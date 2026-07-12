# Voz Urbana

O **Voz Urbana** é um aplicativo mobile desenvolvido em **Flutter** com o objetivo de facilitar o registro e o acompanhamento de problemas urbanos. A aplicação permite que cidadãos relatem ocorrências, como buracos nas vias, iluminação pública defeituosa, descarte irregular de lixo e outros problemas de infraestrutura, contribuindo para uma comunicação mais eficiente entre a população e os órgãos responsáveis.

## Funcionalidades

Atualmente, o aplicativo oferece as seguintes funcionalidades:

* Cadastro e autenticação de usuários;
* Registro de denúncias com fotografia;
* Captura da localização do dispositivo;
* Consulta de estados e municípios por meio da API de Localidades do IBGE;
* Armazenamento local das denúncias utilizando SQLite;
* Histórico das ocorrências registradas;
* Visualização das denúncias em mapa utilizando OpenStreetMap;
* Pesquisa de localidades por meio da API Nominatim;
* Alteração do status das ocorrências;
* Envio das denúncias por e-mail utilizando Web3Forms;
* Alternância entre tema claro e tema escuro.

## Tecnologias Utilizadas

* Flutter
* Dart
* SQLite
* OpenStreetMap
* Nominatim
* API de Localidades do IBGE
* Web3Forms

## Estrutura do Projeto

O projeto segue uma organização baseada em funcionalidades (**Feature First**), facilitando a manutenção e a evolução da aplicação.

```text
lib/
├── core/
├── features/
│   ├── auth/
│   ├── map/
│   ├── report/
│   ├── feed/
│   ├── settings/
│   └── navigation/
└── main.dart
```

## Como Executar

Clone o repositório e instale as dependências:

```bash
flutter pub get
```

Em seguida, execute o aplicativo:

```bash
flutter run
```

## APIs e Serviços Utilizados

O aplicativo integra diferentes serviços para disponibilizar suas funcionalidades:

* **API de Localidades do IBGE**: carregamento dinâmico de estados e municípios.
* **OpenStreetMap**: exibição do mapa da aplicação.
* **Nominatim**: pesquisa de endereços e localidades.
* **Web3Forms**: envio das denúncias por e-mail.

## Melhorias Futuras

Entre as funcionalidades previstas para futuras versões destacam-se:

* Autenticação completa utilizando Firebase;
* Persistência das denúncias em banco de dados remoto;
* Notificações em tempo real;
* Acompanhamento do andamento das ocorrências;
* Painel administrativo para gerenciamento das denúncias;
* Melhorias na interface e na experiência do usuário.

## Equipe

Projeto desenvolvido por:

* Talita Cruz
* Cláudio Vieira

## Licença

Este projeto foi desenvolvido para fins acadêmicos como parte das atividades da Universidade Federal da Bahia (UFBA).
