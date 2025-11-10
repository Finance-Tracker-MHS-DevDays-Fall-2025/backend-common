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

## Генерация кода

```bash
make proto-gen
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

## Использование

```go
import (
    walletpb "github.com/goomer125/finance-tracker/common/proto/wallet"
    masterpb "github.com/goomer125/finance-tracker/common/proto/master"
)

client := walletpb.NewWalletServiceClient(conn)
resp, err := client.GetAccounts(ctx, &walletpb.GetAccountsRequest{
    UserId: "user-123",
    Token: "tbank_api_token",
})
```

## Типы данных

### Money

```protobuf
message Money {
  int64 amount = 1;      // копейки (10000 = 100.00 руб)
  string currency = 2;   // "RUB"
}
```

### TransactionType

- `TRANSACTION_TYPE_INCOME` - доход
- `TRANSACTION_TYPE_EXPENSE` - расход
- `TRANSACTION_TYPE_TRANSFER` - перевод

### AccountType

- `ACCOUNT_TYPE_REGULAR` - обычный счет
- `ACCOUNT_TYPE_INVESTMENT` - инвестиционный

## Технологии

- Go 1.21+
- gRPC + Protobuf
- PostgreSQL 15+
