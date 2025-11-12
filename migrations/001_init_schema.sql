-- Migration: 001_init_schema
-- Description: Initial database schema for finance tracker
-- Database: master

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    login TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tokens table
CREATE TABLE IF NOT EXISTS tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_type TEXT NOT NULL,
    token TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tokens_user_id ON tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_tokens_token ON tokens(token);

-- Accounts table (bank or investment account)
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    balance BIGINT NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT check_account_type CHECK (type IN ('REGULAR', 'INVESTMENT'))
);

CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_type ON accounts(type);

-- Transactions table
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    to_account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    type TEXT NOT NULL,
    amount BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    mcc INTEGER,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT check_transaction_type CHECK (type IN ('INCOME', 'EXPENSE', 'TRANSFER')),
    CONSTRAINT check_positive_amount CHECK (amount > 0)
);

CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_mcc ON transactions(mcc);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_account_date_type ON transactions(account_id, created_at, type);

-- Investment positions table
CREATE TABLE IF NOT EXISTS investment_positions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    security_id TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT check_positive_quantity CHECK (quantity >= 0)
);

CREATE INDEX IF NOT EXISTS idx_investment_positions_account_id ON investment_positions(account_id);
CREATE INDEX IF NOT EXISTS idx_investment_positions_security_id ON investment_positions(security_id);

-- Securities table
CREATE TABLE IF NOT EXISTS securities (
    figi TEXT PRIMARY KEY,
    ticker TEXT,
    name TEXT NOT NULL,
    current_price BIGINT,
    type TEXT NOT NULL,
    price_updated_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT check_security_type CHECK (type IN ('STOCK', 'BOND', 'ETF', 'CURRENCY'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_securities_ticker ON securities(ticker) WHERE ticker IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_securities_type ON securities(type);

-- Securities payments table (dividends)
CREATE TABLE IF NOT EXISTS securities_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    security_id TEXT NOT NULL REFERENCES securities(figi) ON DELETE CASCADE,
    amount_per_share BIGINT NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT check_positive_payment CHECK (amount_per_share > 0)
);

CREATE INDEX IF NOT EXISTS idx_securities_payments_security_id ON securities_payments(security_id);
CREATE INDEX IF NOT EXISTS idx_securities_payments_payment_date ON securities_payments(payment_date);


-- Comments
COMMENT ON TABLE users IS 'User accounts';
COMMENT ON TABLE accounts IS 'Bank and investment accounts';
COMMENT ON TABLE transactions IS 'Financial transactions (income, expense, transfer)';
COMMENT ON TABLE securities IS 'Securities (stocks, bonds, ETF)';
COMMENT ON TABLE securities_payments IS 'Dividend and coupon payments';
COMMENT ON COLUMN transactions.amount IS 'Amount in kopecks (100.00 RUB = 10000)';
COMMENT ON COLUMN accounts.balance IS 'Balance in kopecks';
COMMENT ON COLUMN transactions.mcc IS 'Merchant Category Code for transaction categorization';

