![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)
![ArgoCD](https://img.shields.io/badge/argo-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)

---

# Production-ready платформа для развертывание микросервисов в Kubernetes или Docker

> **Обзор:** Полноценная DevOps-платформа для автоматического развертывания микросервисного приложения (на примере простого "Hello World" API) в кластере Kubernetes. Проект демонстрирует навыки работы с IaC (Terraform), контейнеризацией (Docker), CI/CD (GitHub Actions), оркестрацией (K8s), GitOps (ArgoCD) и мониторингом (Prometheus + Grafana).

--- 



## Содержание

- [Технологический стек](#-технологический-стек)
- [Структура проекта](#-структура-проекта)
- [Предварительные требования](#-предварительные-требования)
- [Быстрый старт](#-быстрый-старт)
- [Компоненты](#-компоненты)
  - [Terraform](#terraform)
  - [Ansible](#ansible)
  - [Kubernetes](#kubernetes)
  - [Мониторинг](#мониторинг)
  - [ArgoCD](#argocd)

---

## Технологический стек

| Категория | Технологии |
| :--- | :--- |
| **Облачная инфраструктура** | Google Cloud Platform (GCP) |
| **Инструменты IaC** | Terraform, Ansible |
| **Контейнеризация** | Docker, Docker Compose |
| **Оркестрация** | Kubernetes (GKE / kubeadm / k3s) |
| **CI/CD** | GitHub Actions, ArgoCD (GitOps) |
| **Мониторинг** | Prometheus, Grafana, Node Exporter, Alertmanager |
| **Логирование** | Loki, Promtail |
| **Безопасность** | Trivy, GitHub Secrets |

---

## Структура проекта

```
homelab/
├── .github/           # GitHub Actions workflows
├── ansible/           # Ansible плейбуки для настройки серверов
├── argocd/            # Манифесты ArgoCD
├── k8s/               # Kubernetes манифесты и приложение
├── monitoring/        # Стек мониторинга (Prometheus, Grafana, Loki)
├── terraform/         # Terraform конфигурация для GCP
└── README.md          # Основная документация
```

---

## Предварительные требования

Убедитесь, что у вас установлены:

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) 3.0+
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 1.0+
- [Ansible](https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html)
- [Google Cloud SDK](https://cloud.google.com/sdk) (для GCP)

---

## Быстрый старт

### 1. Клонирование репозитория

```bash
git clone https://github.com/LeoEliot/homelab.git
cd homelab[Подробная информация](monitoring/README.md)
```

### 2. Развертывание инфраструктуры

#### Через Terraform (GCP)

```bash
cd terraform
cp variables.tfvars.example variables.tfvars
# Отредактируйте variables.tfvars
terraform init
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars"
```

#### Через Ansible (собственные серверы)

```bash
cd ansible
ansible-galaxy install -r requirements.yml
# Настройте inventory/hosts и inventory/group_vars/all.yaml
ansible-playbook site.yml
```

### 3. Развертывание мониторинга

```bash
cd monitoring

# Для Docker
docker-compose up -d

# Для Kubernetes
cd k8s
chmod +x bootstrap.sh
./bootstrap.sh
```

### 4. Подключение к кластеру

```bash
gcloud container clusters get-credentials kubetrain --region=us-west1-a --project=your-project-id
```

---

## Компоненты

### Terraform

Модульная конфигурация для развертывания инфраструктуры в Google Cloud Platform.

[Подробная информация](terraform/README.md)

**Модули:**

- **VPC** — виртуальная частная сеть с публичной и приватной подсетями
- **Cluster** — GKE кластер с автоскейлингом (1-3 ноды)
- **Infrastructure** — ingress-nginx, cert-manager
- **Compute** — управление виртуальными машинами

**Выходные значения:**

- `cluster_name` — имя кластера
- `cluster_endpoints` — endpoint кластера
- `ingress_nginx_ip` — IP-адрес ingress-контроллера
- `vpc_network` — имя VPC сети

---

### Ansible

Конфигурация Ansible для базовой настройки серверов.

[Подробная информация](ansible/README.md)

**Возможности:**

- Создание нового пользователя
- Настройка SSH-доступа
- Установка Docker
- Настройка firewall (HTTP, HTTPS, SSH)

**Использование:**

```bash
cd ansible
ansible-galaxy install -r requirements.yml
ansible-playbook site.yml
```

---

### Kubernetes

Манифесты для развертывания приложения "Hello World" на Flask.

**Структура:**

```
k8s/
├── app/
│   ├── src/app.py         # Flask приложение
│   ├── Dockerfile         # Контейнер
│   └── requirements.txt   # Зависимости Python
└── manifests/
    ├── deployment.yaml    # Deployment для приложения
    └── service.yaml       # Service для exposición приложения
```

**Манифесты:**

| Манифест | Описание |
|----------|----------|
| `deployment.yaml` | Deployment с 1 репликой Flask-приложения на порту 8080 |
| `service.yaml` | ClusterIP Service для внутреннего доступа к приложению |

**Применение манифестов:**

```bash
# Применить все манифесты
kubectl apply -f k8s/manifests/

# Проверить статус
kubectl get pods -l app=demoapp
kubectl get svc demoapp

# Получить логи
kubectl logs -l app=demoapp --tail=50 -f
```

**Параметры приложения:**

- **Порт:** 8080
- **Лейбл селектора:** `app: demoapp`
- **Образ:** `malefstorm1994/demoapp:latest`

---

### Мониторинг

Полный стек мониторинга на базе Prometheus и Grafana.

[Подробная информация](monitoring/README.md)

**Компоненты:**

| Сервис | Назначение | URL |
|--------|------------|-----|
| Grafana | Визуализация и дашборды | http://localhost:3000 |
| Prometheus | Сбор и хранение метрик | http://localhost:9090 |
| Alertmanager | Маршрутизация оповещений | http://localhost:9093 |
| Loki | Агрегация логов | http://localhost:3100 |
| Node Exporter | Системные метрики | http://localhost:9100 |
| cAdvisor | Метрики контейнеров | http://localhost:8080 |

**Учётные данные по умолчанию:**

- Grafana: `admin` / `admin`

**Развертывание в Docker:**

```bash
cd monitoring
docker-compose up -d
```

**Развертывание в Kubernetes:**

```bash
cd monitoring/k8s
./bootstrap.sh
```

---

### ArgoCD

GitOps-оператор для непрерывного развертывания в Kubernetes.

**Возможности:**

- Автоматическая синхронизация манифестов из Git
- Отслеживание состояния приложений
- Rollback при ошибках
- Визуализация топологии приложений

**Структура:**

```
argocd/
└── application.yaml    # Манифест Application для ArgoCD
```

**Установка ArgoCD:**

```bash
# Установка через Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace

# Или через манифесты
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**Доступ к ArgoCD UI:**

```bash
# Port-forward для локального доступа
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Получить пароль администратора
argocd admin initial-password -n argocd

# Или через kubectl
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

**Развертывание Application:**

```bash
# Применить манифест Application
kubectl apply -f argocd/application.yaml

# Синхронизировать приложение вручную
argocd app sync demoapp

# Проверить статус приложения
argocd app get demoapp

# Через kubectl
kubectl get application -n argocd
```

**Параметры Application:**

| Параметр | Значение |
|----------|----------|
| Имя | `demoapp` |
| Namespace | `argocd` / `demoapp` |
| Repo URL | `https://github.com/LeoEliot/homelab.git` |
| Путь | `k8s/manifests` |
| Ревизия | `HEAD` |
| Синхронизация | Ручная / Автоматическая |

**Полезные команды ArgoCD:**

```bash
# Список всех приложений
argocd app list

# Синхронизация приложения
argocd app sync demoapp

# Откат к предыдущей версии
argocd app rollback demoapp

# Удаление приложения
argocd app delete demoapp

# Включение авто-синхронизации
argocd app set demoapp --sync-policy automated
```

---

## Точки доступа после развертывания

| Сервис | Порт | URL |
|--------|------|-----|
| Приложение | 80 | http://ingress-ip |
| Grafana | 3000 | http://localhost:3000 |
| Prometheus | 9090 | http://localhost:9090 |
| ArgoCD | 8080 | http://localhost:8080 |

---

## Полезные команды

### Kubernetes

```bash
# Получить статус подов
kubectl get pods -A

# Получить логи пода
kubectl logs -f <pod-name>

# Применить манифест
kubectl apply -f manifest.yaml

# Удалить ресурс
kubectl delete -f manifest.yaml
```

### Terraform

```bash
# Инициализация
terraform init

# Форматирование
terraform fmt

# Валидация
terraform validate

# Планирование
terraform plan

# Применение
terraform apply

# Уничтожение
terraform destroy
```

### Ansible

```bash
# Проверка соединения
ansible all -m ping

# Запуск плейбука
ansible-playbook site.yml

# Запуск с фильтром тегов
ansible-playbook site.yml --tags "docker"
```

---

## Лицензия

MIT

---

## Полезные ссылки

- [Документация Kubernetes](https://kubernetes.io/docs/)
- [Документация Terraform](https://www.terraform.io/docs)
- [Документация Ansible](https://docs.ansible.com)
- [Документация Prometheus](https://prometheus.io/docs/)
- [Документация Grafana](https://grafana.com/docs/)
- [Документация ArgoCD](https://argo-cd.readthedocs.io/)
