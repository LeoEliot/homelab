# Homelab Terraform Configuration

Terraform-конфигурация для развертывания инфраструктуры homelab в Google Cloud Platform (GCP).

## Структура проекта

```
terraform/
├── main.tf                    # Основной файл конфигурации
├── variables.tf               # Описание переменных
├── variables.tfvars           # Значения переменных (не коммитится)
├── variables.tfvars.example   # Пример значений переменных
├── outputs.tf                 # Выходные значения
├── backend.tf                 # Конфигурация бэкенда состояния
└── modules/                   # Модули Terraform
    ├── vpc/                   # Виртуальная частная сеть
    ├── cluster/               # GKE кластер
    ├── infrastructure/        # Инфраструктурные компоненты
    └── compute/               # Виртуальные машины
```

## Модули

### VPC
Создаёт виртуальную частную сеть с двумя подсетями:
- **home-public** (10.0.1.0/24) — публичная подсеть
- **home-private** (10.0.2.0/24) — приватная подсеть с доступом к Google API

### Cluster
Разворачивает GKE (Google Kubernetes Engine) кластер:
- Управляемый кластер с автоскейлингом (1-3 ноды)
- Тип машины: e2-standard-4
- Отдельный node pool для основных workload'ов

### Infrastructure
Устанавливает инфраструктурные компоненты в кластер через Helm:
- **Ingress NGINX** — контроллер входящего трафика с LoadBalancer
- **Cert-Manager** — управление TLS сертификатами
- Внешний IP-адрес для ingress-контроллера

### Compute
Модуль для управления виртуальными машинами.

## Требования

- [Terraform](https://www.terraform.io/) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk)
- Настроенный gcloud CLI с аутентификацией

## Использование

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd terraform
```

### 2. Настройка переменных

Скопируйте пример и отредактируйте значения:

```bash
cp variables.tfvars.example variables.tfvars
```

Отредактируйте `variables.tfvars`:

```hcl
project_id   = "your-project-id"
region       = "us-west1"
zone         = "us-west1-a"
cluster_name = "kubetrain"
```

### 3. Инициализация

```bash
terraform init
```

### 4. Планирование изменений

```bash
terraform plan -var-file="variables.tfvars"
```

### 5. Применение изменений

```bash
terraform apply -var-file="variables.tfvars"
```

### 6. Получение кредов для kubectl

```bash
gcloud container clusters get-credentials kubetrain --region=us-west1-a --project=your-project-id
```

## Выходные значения

После применения будут доступны следующие значения:

- `cluster_name` — имя кластера
- `cluster_endpoints` — endpoint кластера
- `ingress_nginx_ip` — IP-адрес ingress-контроллера
- `vpc_network` — имя VPC сети
- `vpc_network_public` — имя публичной подсети

## Backend

Состояние Terraform хранится в Google Cloud Storage:

- Бакет: `malefstorm-terraform-state`
- Префикс: `malefstorm-cluster-dev/cluster`

## Провайдеры

- **google** >= 5.0 — для управления ресурсами GCP
- **kubernetes** >= 2.0 — для управления ресурсами Kubernetes
- **helm** — для установки Helm чартов

