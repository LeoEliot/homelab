# Инфраструктура Ansible

## 🗒️ Обзор

Небольшая конфигурация Ansible для развертывния Docker и настройки нового пользователя

## ⚒️ Требования

- **Python3** >= 3.12
- **PIP** >= 25.0

## 🎯 Как использовать

### 1. Установка Ansible

Установите Ansible следующей командой:

```bash
pip install ansible
```

### 2. Установка зависимостей Ansible

Установите Ansible следующей командой:

```bash
ansible-galaxy install -r requirements.yml
```

### 3. Настройка инвентаря

- Отредактируйте файл *hosts* в папке *inventory* и укажите актуальные серверы

- Отредактируйте файл *all.yaml* в папке *inventory/group_vars*, укажите желаемое имя пользвателя и желаемые опции(включение ssh, http, вход на сервер только по ssh)

### 4. Запуск Ansible

Перейдите в папку ansible и выполните:

```bash
ansible-playbook playbooks/site.yml
```

## 🪧 Документация

- [Документация Ansible](https://docs.ansible.com)