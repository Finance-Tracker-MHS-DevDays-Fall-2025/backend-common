# Схема базы данных

Единая PostgreSQL база данных для хранения основных данных.

**Примечание:**

- Wallet и Market сервисы имеют собственный кеш (Redis/in-memory) для данных из внешних API
- MCC (Merchant Category Code) - четырехзначный код категории из банковских транзакций
- Budgets - пользователь указывает MCC и устанавливает лимит

## Основные таблицы

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    login TEXT NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE tokens (
    user_id UUID NOT NULL REFERENCES users(id),
    token_type TEXT NOT NULL,
    token TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- bank or investment account
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    balance BIGINT NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);

CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    account_id UUID NOT NULL REFERENCES accounts(id),
    to_account_id REFERENCES accounts(id) DEFAULT NULL,
    type TEXT NOT NULL,
    amount BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    mcc INTEGER,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_date ON transactions(created_at DESC);
CREATE INDEX idx_transactions_mcc ON transactions(mcc);

-- CREATE TABLE budgets (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     user_id UUID NOT NULL,
--     mcc INTEGER NOT NULL,
--     limit_amount BIGINT NOT NULL,
--     period VARCHAR(50) NOT NULL,
--     spent_amount BIGINT NOT NULL DEFAULT 0,
--     created_at TIMESTAMP NOT NULL DEFAULT NOW()
-- );

-- CREATE INDEX idx_budgets_user_id ON budgets(user_id);
-- CREATE INDEX idx_budgets_mcc ON budgets(mcc);

CREATE TABLE investment_positions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id),
    security_id UUID NOT NULL,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_investment_positions_account_id ON investment_positions(account_id);

CREATE TABLE securities (
    figi TEXT PRIMARY KEY  UNIQUE NOT NULL,
    name TEXT NOT NULL,
    current_price BIGINT,
    type TEXT NOT NULL,
    price_updated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_securities_ticker ON securities(ticker);

CREATE TABLE securities_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    security_id UUID NOT NULL REFERENCES securities(figi),
    amount_per_share BIGINT NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dividends_security_id ON dividends(security_id);
CREATE INDEX idx_dividends_payment_date ON dividends(payment_date);
```

<!-- ## Дополнительная БД для Analyzer (опционально)

Если нужно кешировать тяжелые расчеты или хранить ML модели:

```sql
CREATE TABLE analytics_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    cache_key VARCHAR(255) NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_analytics_cache_user_key ON analytics_cache(user_id, cache_key);
CREATE INDEX idx_analytics_cache_expires ON analytics_cache(expires_at);
```

## Замечания -->

- Все суммы в BIGINT (копейки): 100.00 руб = 10000
- UUID для всех ID
- Индексы на user_id для быстрого доступа
- Timestamp для всех дат
- Notification Service работает без БД (in-memory или очереди)
