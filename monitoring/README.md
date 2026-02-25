# Стек Grafana, Prometheus, Node Opertaor

--- 

## Обзор

Этот репозиторий содержит конфигурационные файлы для развёртывания комплекса мониторинга, включающего:

- **Prometheus** — сбор и хранение метрик
- **Grafana** — визуализация и дашборды
- **Alertmanager** — маршрутизация и управление оповещениями
- **Loki** — агрегация логов
- **Promtail** — агент сбора логов
- **Node Exporter** — экспортёр системных метрик
- **cAdvisor** — экспортёр метрик контейнеров

---

## Развёртывание в Docker

### Требования

- Docker Engine 20.10+
- Docker Compose 2.0+

### Точки доступа

| Сервис        | URL                   | Учётные данные по умолчанию |
|---------------|-----------------------|-----------------------------|
| Grafana       | http://localhost:3000 | admin / admin               |
| Prometheus    | http://localhost:9090 | -                           |
| Alertmanager  | http://localhost:9093 | -                           |
| Loki          | http://localhost:3100 | -                           |
| Node Exporter | http://localhost:9100 | -                           |
| cAdvisor      | http://localhost:8080 | -                           |

---

## Развёртывание в Kubernetes

### Требования

- Kubernetes кластер 1.19+
- настроенный kubectl
- Helm 3.0+

### Быстрый старт с bootstrap-скриптом

```bash
cd k8s
chmod +x bootstrap.sh
./bootstrap.sh
```

Скрипт bootstrap устанавливает:
- **ingress-nginx** — ingress-контроллер
- **cert-manager** — управление TLS-сертификатами через Let's Encrypt
- **kube-prometheus-stack** — полный стек мониторинга

### Учётные данные для Kubernetes

- **Имя пользователя Grafana**: `admin`
- **Пароль Grafana**: `admin`

---

## Конфигурация

### Правила оповещений Prometheus

Отредактируйте `docker/prometheus/alert.rules.yml` для настройки правил:

```yaml
groups:
  - name: example_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        annotations:
          summary: "Обнаружена высокая загрузка CPU"
```

### Маршруты Alertmanager

Отредактируйте `docker/alertmanager/alertmanager.yml` для настройки маршрутизации оповещений:

```yaml
receivers:
  - name: 'email-receiver'
    email_configs:
      - to: 'admin@example.com'
        from: 'alertmanager@example.com'
```

### Провижининг Grafana

Источники данных Grafana автоматически настраиваются из:
- `docker/grafana/provisioning/datasources/prometheus.yaml`
- `docker/grafana/provisioning/datasources/alertmanager.yaml`

---

### Очистка

```bash
# Docker
docker-compose down -v

# Kubernetes
helm uninstall prometheus-stack -n monitoring
kubectl delete namespace monitoring
```
---

## Структура проекта

```
monitoring/
├── docker/
│   ├── docker-compose.yaml
│   ├── grafana/
│   │   └── provisioning/
│   │       └── datasources/
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── alert.rules.yml
│   ├── alertmanager/
│   │   └── alertmanager.yml
│   ├── loki/
│   │   └── loki-config.yaml
│   └── promtail/
│       └── promtail-config.yaml
└── k8s/
    ├── bootstrap.sh
    └── kube-prometheus-stack/
        └── values.yaml
```

---

## Лицензия

MIT

---

## Полезные ссылки

- [Документация Prometheus](https://prometheus.io/docs/)
- [Документация Grafana](https://grafana.com/docs/)
- [Документация Loki](https://grafana.com/docs/loki/latest/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)