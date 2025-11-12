-- Migration: 002_seed_data
-- Description: Seed data for testing
-- Database: master

-- Insert test user
INSERT INTO users (id, login, password, created_at) 
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'test_user', 'hashed_password', NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert test accounts
INSERT INTO accounts (id, user_id, name, type, balance, currency, created_at)
VALUES
    ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000001', 'Основной счет', 'REGULAR', 5000000, 'RUB', NOW()),
    ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000001', 'Инвестиционный счет', 'INVESTMENT', 10000000, 'RUB', NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert test transactions
INSERT INTO transactions (id, account_id, type, amount, currency, mcc, description, created_at)
VALUES
    (gen_random_uuid(), '00000000-0000-0000-0000-000000000101', 'INCOME', 15000000, 'RUB', NULL, 'Зарплата', NOW() - INTERVAL '30 days'),
    (gen_random_uuid(), '00000000-0000-0000-0000-000000000101', 'EXPENSE', 5000000, 'RUB', 5411, 'Продукты', NOW() - INTERVAL '25 days'),
    (gen_random_uuid(), '00000000-0000-0000-0000-000000000101', 'EXPENSE', 3000000, 'RUB', 5812, 'Ресторан', NOW() - INTERVAL '20 days'),
    (gen_random_uuid(), '00000000-0000-0000-0000-000000000101', 'EXPENSE', 2000000, 'RUB', 4121, 'Такси', NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), '00000000-0000-0000-0000-000000000101', 'INCOME', 15000000, 'RUB', NULL, 'Зарплата', NOW() - INTERVAL '60 days'),
    (gen_random_uuid(), '00000000-0000-0000-0000-000000000101', 'EXPENSE', 4500000, 'RUB', 5411, 'Продукты', NOW() - INTERVAL '55 days')
ON CONFLICT (id) DO NOTHING;

-- Insert test securities
INSERT INTO securities (figi, ticker, name, type, current_price, created_at)
VALUES
    ('BBG004730N88', 'SBER', 'Сбербанк', 'STOCK', 27000, NOW()),
    ('BBG004731354', 'GAZP', 'Газпром', 'STOCK', 15000, NOW()),
    ('BBG004730ZJ9', 'YNDX', 'Яндекс', 'STOCK', 350000, NOW())
ON CONFLICT (figi) DO NOTHING;

COMMENT ON SCHEMA public IS 'Test data loaded for development';

