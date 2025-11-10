# Архитектура системы отслеживания финансов

## Обзор

Микросервисная архитектура для управления личными финансами с поддержкой счетов, транзакций, инвестиций, аналитики и прогнозирования.

## Компоненты системы

### 1. Master Service

Агрегатор и API Gateway для фронтенда. Принимает HTTP запросы, вызывает другие сервисы по gRPC, агрегирует ответы.

**Порт:** 8080 (HTTP)

### 2. Wallet Service

Прокси для внешних API банков (Т-Банк). Получает счета, транзакции через внешний API. Имеет собственный кеш (Redis/in-memory).

**Порт:** 50051 (gRPC)

### 3. Market Service

Прокси для рыночных данных. Получает информацию о ценных бумагах, цены, дивиденды через внешние API. Имеет собственный кеш (Redis/in-memory).

**Порт:** 50052 (gRPC)

### 4. Analyzer Service

Аналитика транзакций, прогнозирование баланса. Может иметь свою дополнительную БД для кеша/ML моделей.

**Порт:** 50053 (gRPC)

### 5. Notification Service

Отправка уведомлений. Работает in-memory или через очередь.

**Порт:** 50054 (gRPC)

## Схема взаимодействия

```
Frontend (HTTP) → Master Service (gRPC) → Wallet / Market / Analyzer / Notification
```

## Use Cases

### 1. Ручной ввод транзакции

Frontend → Master.CreateTransaction → Wallet.CreateTransaction

### 2. Просмотр баланса

Frontend → Master.GetBalance → Wallet.ListAccounts + Market.CalculatePortfolioValue

### 3. Аналитика по категориям

Frontend → Master.GetAnalytics → Analyzer.GetStatistics → Wallet.ListTransactions

### 4. Прогноз баланса

Frontend → Master.GetForecast → Analyzer.GetForecast

### 5. Уведомления

Scheduler → Notification.SendNotification

## Технологический стек

- Go 1.21+
- gRPC + Protobuf
- PostgreSQL 15+
- Redis (кеш в Master)

## База данных

Единая PostgreSQL база данных для хранения основных данных.

**Таблицы:**

- accounts - счета
- transactions - транзакции
- categories - категории пользователя
- budgets - бюджеты пользователя
- investment_positions - инвестиционные позиции
- securities - ценные бумаги
- dividends - дивиденды

**Кеширование:**

- **Wallet Service** - собственный кеш (Redis/in-memory) для данных из Т-Банк API
- **Market Service** - собственный кеш (Redis/in-memory) для рыночных данных
- **Master Service** - Redis для агрегированных данных
- **Analyzer** - может иметь дополнительную БД для ML/расчетов

## Внешние API

- **Т-Банк API** - счета, транзакции, инвестиции
- **Рыночные данные** - цены ЦБ, дивиденды

## Денежные суммы

Хранятся в BIGINT как копейки:

- 100.00 руб = 10000 копеек

```protobuf
message Money {
  int64 amount = 1;      // копейки
  string currency = 2;   // "RUB"
}
```

## Развертывание

Каждый сервис в отдельном репозитории:

- `finance-tracker-master`
- `finance-tracker-wallet`
- `finance-tracker-market`
- `finance-tracker-analyzer`
- `finance-tracker-notification`

Общие proto контракты в репозитории `finance-tracker-common`.
