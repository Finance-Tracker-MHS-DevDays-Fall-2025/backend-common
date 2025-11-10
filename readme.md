# Finance Tracker - API Контракты

Proto контракты для микросервисной системы отслеживания финансов.

## Сервисы

1. **Master Service** - API Gateway (HTTP → gRPC)
2. **Wallet Service** - счета, транзакции, категории
3. **Market Service** - ценные бумаги, дивиденды
4. **Analyzer Service** - аналитика, прогнозы
5. **Notification Service** - уведомления

## Архитектура

```
Frontend → Master Service → {Wallet, Market, Analyzer, Notification}
```

## Документация

- [ARCHITECTURE.md](./ARCHITECTURE.md) - архитектура системы
- [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - схемы БД

## Структура

```
proto/
  common/       - общие типы (Money, TransactionType, etc)
  wallet/       - Wallet Service API (3 endpoints) - прокси для Т-Банк API
  market/       - Market Service API (3 endpoints) - прокси для рыночных данных
  analyzer/     - Analyzer Service API (2 endpoints)
  notification/ - Notification Service API (3 endpoints)
  master/       - Master Service API (4 endpoints)
```
