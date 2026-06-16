-- ============================================================
-- Driver App Tables
-- ============================================================

-- 1. driver_users — WMS admin creates/manages driver accounts
CREATE TABLE IF NOT EXISTS driver_users (
  id           SERIAL PRIMARY KEY,
  username     TEXT UNIQUE NOT NULL,
  password     TEXT NOT NULL,
  driver_name  TEXT NOT NULL DEFAULT '',
  truck_plate  TEXT NOT NULL DEFAULT '',
  active       BOOLEAN NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE driver_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "driver_users_all" ON driver_users;
CREATE POLICY "driver_users_all" ON driver_users FOR ALL USING (true) WITH CHECK (true);
GRANT ALL ON driver_users TO anon, service_role;
GRANT USAGE, SELECT ON SEQUENCE driver_users_id_seq TO anon, service_role;

-- 2. delivery_confirmations — per-shop delivery status per plan
CREATE TABLE IF NOT EXISTS delivery_confirmations (
  id              BIGSERIAL PRIMARY KEY,
  plan_id         TEXT NOT NULL,
  shop_id         TEXT NOT NULL DEFAULT '',
  shop_name       TEXT NOT NULL DEFAULT '',
  shop_seq        INTEGER NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'pending', -- pending / delivered / failed
  note            TEXT NOT NULL DEFAULT '',
  driver_username TEXT NOT NULL DEFAULT '',
  confirmed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE delivery_confirmations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "delivery_confirmations_all" ON delivery_confirmations;
CREATE POLICY "delivery_confirmations_all" ON delivery_confirmations FOR ALL USING (true) WITH CHECK (true);
GRANT ALL ON delivery_confirmations TO anon, service_role;
GRANT USAGE, SELECT ON SEQUENCE delivery_confirmations_id_seq TO anon, service_role;
CREATE INDEX IF NOT EXISTS idx_delconf_plan   ON delivery_confirmations (plan_id);
CREATE INDEX IF NOT EXISTS idx_delconf_driver ON delivery_confirmations (driver_username);
CREATE INDEX IF NOT EXISTS idx_delconf_status ON delivery_confirmations (status);

-- 3. driver_work_logs — daily odometer + time log
CREATE TABLE IF NOT EXISTS driver_work_logs (
  id               BIGSERIAL PRIMARY KEY,
  driver_username  TEXT NOT NULL,
  plan_id          TEXT NOT NULL DEFAULT '',
  work_date        DATE NOT NULL,
  odometer_start   NUMERIC NOT NULL DEFAULT 0,
  odometer_end     NUMERIC NOT NULL DEFAULT 0,
  time_depart      TEXT NOT NULL DEFAULT '',
  time_arrive      TEXT NOT NULL DEFAULT '',
  note             TEXT NOT NULL DEFAULT '',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE driver_work_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "driver_work_logs_all" ON driver_work_logs;
CREATE POLICY "driver_work_logs_all" ON driver_work_logs FOR ALL USING (true) WITH CHECK (true);
GRANT ALL ON driver_work_logs TO anon, service_role;
GRANT USAGE, SELECT ON SEQUENCE driver_work_logs_id_seq TO anon, service_role;
CREATE INDEX IF NOT EXISTS idx_dworklog_driver ON driver_work_logs (driver_username);
CREATE INDEX IF NOT EXISTS idx_dworklog_date   ON driver_work_logs (work_date);
