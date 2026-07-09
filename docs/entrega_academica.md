# Entrega academica - Voz Urbana

## Proposta

O Voz Urbana e um aplicativo para registrar e acompanhar problemas urbanos,
como buracos em vias, iluminacao publica, lixo acumulado, esgoto, arvores
caidas e outros problemas de infraestrutura.

O cidadao registra uma denuncia com foto, categoria, descricao e localizacao.
Depois disso, o aplicativo salva a ocorrencia com protocolo, exibe o registro
no historico, mostra o ponto no mapa e envia um e-mail demonstrativo para o
orgao responsavel.

## Requisitos atendidos

### Inovacao

- Resolve um problema real de comunicacao entre cidadaos e orgaos publicos.
- Centraliza denuncia, localizacao, foto, historico e mapa em um unico fluxo.
- Simula o encaminhamento automatico para o orgao responsavel por e-mail.
- Permite acompanhar status e protocolo da ocorrencia registrada.

### Persistencia de dados

- As denuncias sao salvas localmente usando SQLite.
- O historico consulta os registros persistidos.
- O mapa reutiliza as denuncias salvas para exibir marcadores reais.
- O usuario pode alterar status e excluir registros locais de teste.

### Recursos do dispositivo

- Camera: usada para anexar uma foto da denuncia.
- GPS/localizacao: usado para registrar onde o problema foi encontrado.
- Permissoes nativas: camera e localizacao sao solicitadas ao usuario.
- Internet: usada para consultar municipios do IBGE e enviar e-mail demonstrativo.

### UI/UX

- Fluxo principal organizado em tres abas: mapa, denuncia e historico.
- Login/cadastro demonstrativos com validacoes minimas.
- Mensagens de erro e sucesso para camera, localizacao, cadastro, login e envio.
- Historico com detalhes da denuncia, foto, protocolo, status e acoes.
- Tema claro/escuro.
- Estado de carregamento em acoes demoradas, como foto, localizacao e envio.

## Fluxo para demonstracao

1. Entrar com o usuario `teste@vozurbana.com` e senha `123456`, ou usar Google/Gov.br demonstrativo.
2. Abrir a aba `Denunciar`.
3. Permitir acesso a localizacao.
4. Tirar uma foto autorizando a camera.
5. Selecionar a categoria da denuncia.
6. Informar uma descricao opcional.
7. Enviar a denuncia.
8. Conferir o protocolo gerado.
9. Conferir a denuncia na aba `Historico`.
10. Abrir os detalhes, alterar o status e observar o badge visual.
11. Conferir o marcador da denuncia na aba `Mapa`.
12. Verificar o envio demonstrativo para `talitawct3@gmail.com`.

## Configuracoes externas necessarias

- Confirmar conexao com internet para carregar o mapa OpenStreetMap.
- Confirmar o primeiro e-mail recebido pelo FormSubmit, caso a plataforma solicite.
- Rodar o app em dispositivo/emulador com camera e localizacao habilitadas.

## Limitacoes assumidas por pragmatismo

- Google e Gov.br usam login demonstrativo com usuarios predefinidos.
- O envio de e-mail usa FormSubmit, sem backend proprio.
- As denuncias sao persistidas localmente no dispositivo, nao em servidor remoto.
