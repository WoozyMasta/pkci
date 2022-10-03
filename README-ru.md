
<!--
PKCI
Pumped Kaniko Container Image for Continuous Integration
===============================================================================

Лицензия: MIT
Авторские права 2022 WoozyMasta <me@woozymasta.ru>

Данная лицензия разрешает лицам, получившим копию данного программного
обеспечения и сопутствующей документации (в дальнейшем именуемыми
«Программное обеспечение»), безвозмездно использовать Программное
обеспечение без ограничений, включая неограниченное право на использование,
копирование, изменение, слияние, публикацию, распространение,
сублицензирование и/или продажу копий Программного обеспечения, а также
лицам, которым предоставляется данное Программное обеспечение, при
соблюдении следующих условий:

Указанное выше уведомление об авторском праве и данные условия должны быть
включены во все копии или значимые части данного Программного обеспечения.

ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ КАКИХ-ЛИБО
ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ ГАРАНТИИ ТОВАРНОЙ
ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И ОТСУТСТВИЯ
НАРУШЕНИЙ, НО НЕ ОГРАНИЧИВАЯСЬ ИМИ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ
ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО КАКИМ-ЛИБО ИСКАМ, ЗА УЩЕРБ ИЛИ
ПО ИНЫМ ТРЕБОВАНИЯМ, В ТОМ ЧИСЛЕ, ПРИ ДЕЙСТВИИ КОНТРАКТА, ДЕЛИКТЕ ИЛИ ИНОЙ
СИТУАЦИИ, ВОЗНИКШИМ ИЗ-ЗА ИСПОЛЬЗОВАНИЯ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫХ
ДЕЙСТВИЙ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.

===============================================================================
# Файл был сгенерирован автоматически
# ⚠️ Не редактируйте его самостоятельно перед публикацией изменений в проекте ⚠️

Сгенерировано: 2022-06-30T16:13:36+00:00
-->

# PKCI

Pumped Kaniko Container Image for Continuous Integration

![logo][]

> _**P**umped **K**aniko **C**ontainer **I**mage_ or
> _**P**umped **K**aniko for **C**ontinuous **I**ntegration_  
> Прокачанный образ контейнера Kaniko _или_
> Прокачанная Kaniko для непрерывной интеграции

## Описание

Это альтернативный образ контейнера [kaniko][], дополненный установленными утилитами [busybox][], [bash][], [jq][] и прочими полезностями.

> [kaniko][] — это инструмент для создания образов контейнеров из `Dockerfile`
> внутри контейнера или кластера [kubernetes][].
>
> kaniko не зависит от демона Docker и выполняет каждую команду в `Dockerfile`
> полностью в пользовательском пространстве. Это позволяет создавать образы
> контейнеров в средах, которые не могут легко или безопасно запускать демон
> Docker, например в стандартном кластере [kubernetes][].

Причина появления **PKCI** — это необходимость выполнить дополнительную логику внутри контейнера при сборке образа. Оригинальный образ kaniko поставляется на основе scratch-образа, а только отладочный контейнер содержит всего лишь один busybox.

![scheme][]

Одного busybox оказалось недостаточно в связи с этим и появился данный контейнер, что решает задачи:

* В оригинальном отладочном контейнере используется устаревший [busybox][] `1.32.0`
* busybox установлен по пути `/busybox`, что иногда вызывает проблему на некоторых CRI и при использовании ключа `--cleanup` (когда вы создаете больше одного образа), kaniko по умолчанию исключает только каталог `/kaniko`, а все остальные пути исключаются по параметру `VOLUME` в `Dockerfile`. `VOLUME` может быть проигнорирован вашим CRI и проблема решается только использованием ключа `--ignore-path /busybox`, что не очевидно.  
  В связи с этим все бинарные файлы размещены в каталоге `/kaniko/bin`
* Когда вы хотите не только собрать контейнер, но еще опубликовать README.md в реестр контейнеров или проверить `Dockerfile` при помощи [hadolint][], вам следует запустить отдельное задание в сборочной линии, а это ожидание создания очередного pod и клонирования репозитория, объединив все необходимые для разработки и публикации контейнеров утилиты в один образ, мы очень хорошо выигрываем в скорости выполнения сборочной линии
* Как оказалось, многим разработчикам непривычно работать с [busybox][] и его реализацией `sh` (Bourne SHell), что порой вызывает трудности в освоении. По этому в контейнер был добавлен [bash][] (Bourne Again SHell) для большего удобства
* Контейнер укомплектован статичными версиями утилит, т.е. утилитами которые не имеют динамических зависимостей к библиотекам, благодаря чему удалось сохранить базовый scratch образ. А именно это:
  * Bash - <https://github.com/robxu9/bash-static>
  * OpenSSL - <https://github.com/ep76/docker-openssl-static>
  * Curl - <https://github.com/moparisthebest/static-curl>
* Довольно частый случай, когда необходимо обратится в какой нибудь API и получить или отправить данные, при этом необходимо удобство в работе с JSON структурами. По этому в образ по умолчанию добавлен знакомый всем [curl][] и [jq][]

## Образы контейнера

Существует 3 версии контейнера, стандартный, slim и extra.
Стандартный образ имеет тег latest
, а альтернативные версии `slim-latest` и `extra-latest`
соответственно.

Также образы доступны из трёх реестров контейнеров:
* [ghcr.io/woozymasta/pkci][ghcr]  
  `latest`, `slim-latest`, `extra-latest`
* [quay.io/woozymasta/pkci][quay]  
  `latest`, `slim-latest`, `extra-latest`
* [docker.io/woozymasta/pkci][docker]  
  `latest`, `slim-latest`, `extra-latest`

### Размер образов

* **pkci:slim** — `19M`
* **pkci:normal** — `84M`
* **pkci:extra** — `164M`

## Важно знать

> ⚠️ **Важно**  
> Ознакомьтесь с этим разделом перед началом использования

### UPX

Для сжатия бинарных файлов в проекте используется [UPX][], это позволяет сократить размер образов в 2.5 раза, но теоретически может помешать вам, по причинам:

- могут быть окружения, в которых самораспаковывающиеся сжатые исполняемые файлы запрещены
- UPX не поддерживает некоторые платформы
- есть очень небольшая вероятность того, что сжатый двоичный файл может иметь некоторую форму ошибки, связанной со сжатием

### Bash и утилиты

В контейнере используется набор утилит из [busybox][] и [bash][] — это не тоже самое, что и [GNU core utilities][coreutils], будьте внимательны при написании скриптов, поведение или параметры привычных утилит таких как `grep`, `sed`, `readlink` и подобных может отличатся от того, что имеется в вашей системе.

### Shebang

Старайтесь не использовать стандартный [shebang][] (к примеру `#!/usr/bin/env bash`) или запускать сценарии через интерпретатор по стандартному пути (к примеру `/bin/bash script.sh`).

В контейнере для простоты и удобства существуют символьные ссылки:

  * `/bin/sh` → `/kaniko/bin/sh`
  * `/bin/bash` → `/kaniko/bin/bash`
  * `/usr/bin/env` → `/kaniko/bin/env`

Но они размещены за границами исключений, и при выполнении очистки окружения (`--cleanup`) будут удалены. Так как это стандартные системные каталоги, мы не можем исключать их глобально, так как это может нарушить целостность и качество сборки в некоторых случаях.

Просто примите это как правило и используйте shebang вида `#!/kaniko/bin/bash` или вызывайте интерпретатор по пути `/kaniko/bin/bash script.sh`

### Path

Переменная окружения `PATH` по умолчанию установлена в значение `/usr/local/bin:/kaniko/bin:/kaniko`. При этом каталог `/usr/local/bin` не существует в образе, по умолчанию все бинарные файлы будут использоваться из `/kaniko/bin` и `/kaniko` пока не появится `/usr/local/bin`

### Executor

По умолчанию в стандартном образе бинарный файл kaniko называется `executor` и расположен по пути `/kaniko/executor`. Что бы не нарушать совместимость, это сохранено как есть, но для удобства также создана символическая ссылка `/kaniko/bin/kaniko` ссылающаяся на `/kaniko/executor`

### Docker credential helpers

* [docker-credential-acr-env][]
* [docker-credential-gcr][]
* [docker-credential-ecr-login][]

Эти утилиты используются тех же версий и с тем же наименованием как в составе оригинального образа kaniko. Сделано это для соблюдения обратной совместимости, но их расположение перемещено в общий каталог бинарных файлов `/kaniko/bin`. По этому будьте осторожны, вызывайте их по новому абсолютному пути или используйте просто имя для получения их из `$PATH`

* `/kaniko/docker-credential-acr-env`
  → `/kaniko/docker-credential-acr-env` или `docker-credential-acr-env`
* `/kaniko/docker-credential-gcr`
  → `/kaniko/docker-credential-gcr` или `docker-credential-gcr`
* `/kaniko/docker-credential-ecr-login`
  → `/kaniko/docker-credential-ecr-login` или `docker-credential-ecr-login`

### Trivy

> ℹ️ **Информация**  
> Только для `extra` редакции образа. Только в нем используется [trivy][]

Каталог `/contrib` перемещен в `/kaniko/contrib`, по этому при использовании шаблона для формирования отчета указывайте абсолютный путь к файлу, к примеру `/kaniko/contrib/junit.tpl`

Каталог для кеширования также перемещен в `/kaniko/.cache` и установлена переменная окружения `TRIVY_CACHE_DIR=/kaniko/.cache`

Образ не имеет в себе встроенной [базы уязвимостей][trivy-db] для [trivy][], по этому для больших проектов или команд следует задуматься о развертывании отдельного [сервера][trivy-server] Trivy в общей сети со сборочными агентами или собирать по расписанию (раз в 6-12 часов) образ с дополнительным слоем хранящим базу, [подробнее здесь][trivy-air-gap]

## Как это использовать

Образ контейнера поставляется в трех редакциях `slim`, `normal` и `extra` в виду того, что предполагается три основных сценария применения.

Конечно же в вашем случае это может быть абсолютно свой уникальный сценарий который решает именно ваши задачи.

### Slim редакция

Это легковесная версия образа, всего `19M`,
учитывая то что сама [kaniko][] имеет размер около `34M`. Также здесь имеется еще набор утилит [busybox][], [bash][], [curl][], [jq][], [hadolint][] и [docker-pushrm][], которые привносят большую свободу для автоматизации накладывая при этом скоромный дополнительный объем к размеру образа.
Да, именно `19M` против `34M` в оригинале, а всё это лагодаря [UPX][] сжатию бинарных файлов.

![scheme-slim][]

> _Проверь, собери и задокументируй_

Данная редакция подойдет для целей:

* Реализовать сценарий автоматики на `bash`/`sh` с использованием утилит из комплекта [busybox]
* Для работы с JSON и API предоставлены [curl] и [jq], при помощи которых вы можете удобно получить необходимую информацию, к примеру версию зависимости из github API и передать её как ARG в ваш `Dockerfile` не захламляя его лишней логикой или уведомить внешнюю систему о событии вызвав какой нибудь webhook или API запрос.
* Перед сборкой проанализировать `Dockerfile` при помощи [hadolint][] и отправить отчет с статусом анализа при помощи [curl][] в какую нибудь внешнюю систему, к примеру [sonarqube][]
* Естественно собрать и опубликовать образ контейнера при помощи [kaniko][], это наша исходная задача
* И в завершении, после успешной публикации образа контейнера, хорошо будет обновить описание для него. Опубликуем `README.md` или подобный файл в поддерживаемый реестр контейнеров ([dockerhub][], [projectquay][], [quay][] и [harbor][]) при помощи [docker-pushrm][]


### Normal редакция

В отличии от `slim` версии, размер этого образа уже имеет заметные `84M`. Данная в первую очередь редакция имеет набор утилит нацеленных на безопасность, утилиты [cosign][] и [notary-signer][notary] помогут вам [подписать][image signing] ваш образ, а [openssl][] это полноценная криптографическая библиотека которая поможет вам в решении многих задач криптографии.

![scheme-normal][]

> _Шаблонизируй, проверь, собери, подпиши и задокументируй_

Данная редакция подойдет для тех же целей, что и `slim` версия и дополнительно:

* Утилита [crane][] позволит мутировать, анализировать образы и работать с уже опубликованными образами.
* Для решения криптографических задач вы сможете использовать [cosign][], [notary-signer][notary] и [openssl][]
* Вы сможете шаблонизировать ваши `Dockerfile` или markdown документы при помощи [templar][], который предоставляет Jinja2 подобный синтаксис
* Используя утилиту [tokei][] вы сможете проанализировать размер вашего проекта, количество строк кода и комментариев по типам файлов и языкам программирования
* Утилита [mdtohtml][] позволит вам конвертировать markdown документы в HTML. Это может пригодится к примеру перед публикацией вашего `README.md` написанном используя [GFM][] в реестр контейнеров [projectquay][] или [quay][] который поддерживает только [commonmark][], т.е. такие элементы как таблицы просто не будут отображаться корректно, но опубликовав HTML вы получите ожидаемый результат.
* Для авторизации в [GCR][], [ACR][] и [ECR][] имеются соответствующие утилиты как и в оригинальном образе kaniko

### Extra редакция

Редакция `extra` — это самая прокачанная версия образа размером аж в `164M`. Да, этот образ действительно получился большой, на столько же большой как и его возможности, а именно это непрерывная интеграция с оркестраторами контейнеров на базе [kubernetes][] и безопасность размещаемых в нем ресурсов.

![scheme-extra][]

> _Шаблонизируй, проверь, собери, подпиши, задокументируй,_
> _проанализируй и разверни_

В этой редакции есть всё что было в `normal` и `slim`, а еще:

* Имеется [yq][] — процессор командной строки для работы с YAML, JSON и XML.
* Для более серьезной шаблонизации проекта вы можете использовать [gomplate][]
* При помощи [trivy][] вы можете просканировать итоговый собранный образ на наличие CVE, проанализировать git репозиторий проекта на утечку токенов или паролей или даже проверить конфигурацию вашего [kubernetes][] кластера.
* Перед применением YAML манифестов, [kustomize][] и [helm][]-чартов в кластер [kubernetes][] вы можете предварительно проверить их при помощи утилит [kube-linter][] и [kubesec][]
* Для доставки приложений в кластер имеется как уже знакомые всем [kubectl][] и [helm][], так и более универсальные инструменты [jsonnet-bundler][] и [tanka][] для описания конфигурации приложений при помощи [jsonnet][]

## Компоненты контейнеров

Slim | Normal _(+Slim)_ | Extra _(+Normal)_
|-------------------------|-------------------------|-------------------------|
[kaniko][] `1.8.1` | [cosign][] `1.9.0` | [yq][] `4.25.2`
[busybox][] `1.34.1` | [notary][] `0.7.0` | [gomplate][] `3.11.1`
[bash][] `5.1.016-1.2.3` | [openssl][] `3.0.3` | [trivy][] `0.29.2`
[curl][] `7.83.1` | [crane][] `0.9.0` | [kube-linter][] `0.3.0`
[jq][] `1.6` | [mdtohtml][] `latest` | [kubesec] `2.11.4`
[hadolint][] `2.10.0` | [templar][] `0.5.1` | [kubectl][] `1.24.1`
[docker-pushrm][] `1.8.1` | [tokei][] `12.1.2` | [helm][] `3.9.0`
Утилиты | [docker-credential-acr-env][]<br>[docker-credential-gcr][]<br>[docker-credential-ecr-login][] | [jsonnet-bundler][] `0.5.1`
&nbsp; | &nbsp; | [tanka][] `0.22.1`


<!-- links -->

<!-- assets -->
[logo]: ./assets/logo.png "PKCI Logo"
[scheme]: ./assets/scheme.png "PKCI editions scheme"
[scheme-slim]: assets/pkci-slim.png "PKCI slim scheme"
[scheme-normal]: assets/pkci-normal.png "PKCI normal scheme"
[scheme-extra]: assets/pkci-extra.png "PKCI extra scheme"

<!-- image -->
[ghcr]: https://github.com/WoozyMasta/pkci/pkgs/container/pkci
[quay]: https://quay.io/repository/woozymasta/pkci
[docker]: https://hub.docker.com/r/woozymasta/pkci

<!-- slim -->
[kaniko]: https://github.com/GoogleContainerTools/kaniko "Build Container Images In Kubernetes"
[busybox]: https://busybox.net "BusyBox combines tiny versions of many common UNIX utilities into a single small executable."
[bash]: https://www.gnu.org/software/bash/ "Bash is the GNU Project's shell—the Bourne Again SHell"
[hadolint]: https://github.com/hadolint/hadolint "Dockerfile linter, validate inline bash, written in Haskell "
[docker-pushrm]: https://github.com/christian-korneck/docker-pushrm "Docker plugin to update container repo docs "
[jq]: https://stedolan.github.io/jq/ "jq is a lightweight and flexible command-line JSON processor"
[curl]: https://curl.se "command line tool and library for transferring data with URLs"

<!-- normal -->
[cosign]: https://github.com/sigstore/cosign "Container Signing, Verification and Storage in an OCI registry"
[notary]: https://github.com/notaryproject/notary "Notary signer, which stores private keys for and signs metadata for the Notary server"
[openssl]: https://www.openssl.org "full-featured toolkit for general-purpose cryptography and secure communication"
[crane]: https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md "Crane is a tool for managing container images"
[mdtohtml]: https://github.com/gomarkdown/mdtohtml "Command-line tool to convert markdown"
[templar]: https://github.com/proctorlabs/templar/ "Dynamic rust templating framework"
[tokei]: https://github.com/XAMPPRocky/tokei "Tokei is a program that displays LOC statistics about your code."
[docker-credential-acr-env]: https://github.com/chrismellard/docker-credential-acr-env "Azure Container Registry credential helpers"
[docker-credential-gcr]: https://github.com/GoogleCloudPlatform/docker-credential-gcr "Google Container Registry credential helpers"
[docker-credential-ecr-login]: https://github.com/awslabs/amazon-ecr-credential-helper "Amazon Elastic Container Registry credential helpers"

<!-- extra -->
[yq]: https://github.com/mikefarah/yq "yq is a portable command-line YAML, JSON and XML processor "
[trivy]: https://github.com/aquasecurity/trivy "Scanner for vulnerabilities in container images"
[gomplate]: https://docs.gomplate.ca "gomplate is a template renderer tool"
[kubectl]: https://github.com/kubernetes/kubectl "Kubernetes command line tool"
[helm]: https://github.com/helm/helm "The package manager for Kubernetes"
[jsonnet-bundler]: https://github.com/jsonnet-bundler/jsonnet-bundler "The jsonnet-bundler is a package manager for Jsonnet"
[tanka]: https://github.com/grafana/tanka "Flexible, reusable and concise configuration for Kubernetes"
[kube-linter]: https://github.com/stackrox/kube-linter "KubeLinter is a static analysis tool that checks Kubernetes YAML files and Helm charts"
[kubesec]: https://github.com/controlplaneio/kubesec "Security risk analysis for Kubernetes resources "

<!-- other -->
[shebang]: https://en.wikipedia.org/wiki/Shebang_(Unix) "shebang is the character sequence consisting of the characters number sign and exclamation mark (#!) at the beginning of a script"
[sonarqube]: https://www.sonarqube.org "Code Quality and Code Security platform"
[dockerhub]: https://hub.docker.com "Docker Hub is the world's largest library and community for container images"
[projectquay]: https://www.projectquay.io "Project Quay builds, stores, and distributes your container images"
[quay]: https://quay.io/ "Quay builds, stores, and distributes your container images"
[harbor]: https://goharbor.io "Harbor is an open source registry that secures artifacts with policies and role-based access control"
[image signing]: https://dlorenc.medium.com/notary-v2-and-cosign-b816658f044d
[GFM]: https://github.github.com/gfm/ "GitHub Flavored Markdown"
[commonmark]: https://commonmark.org "A strongly defined, highly compatible specification of Markdown"
[kubernetes]: https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/ "Kubernetes is a portable, extensible, open source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation."
[GCR]: https://cloud.google.com/container-registry "Google Container Registry"
[ACR]: https://docs.microsoft.com/azure/container-registry "Azure Container Registry"
[ECR]: https://aws.amazon.com/ecr/ "Amazon Elastic Container Registry"
[trivy-server]: https://aquasecurity.github.io/trivy/latest/docs/references/modes/client-server/
[trivy-air-gap]: https://aquasecurity.github.io/trivy/latest/docs/advanced/air-gap/
[trivy-db]: https://aquasecurity.github.io/trivy/latest/docs/vulnerability/examples/db/
[kustomize]: https://kustomize.io "Kubernetes native configuration management "
[jsonnet]: https://jsonnet.org "A data templating language for app and tool developers"
[coreutils]: https://www.gnu.org/software/coreutils/ "The GNU Core Utilities are the basic file, shell and text manipulation utilities of the GNU operating system. "
[UPX]: https://github.com/upx/upx "the Ultimate Packer for eXecutables"
