-- ============================================
-- ESP32 IoT Devices Schema for AWCMS
-- ============================================

-- Devices Table
CREATE TABLE IF NOT EXISTS public.devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  device_name TEXT,
  device_type TEXT DEFAULT 'esp32',
  ip_address TEXT,
  mac_address TEXT,
  firmware_version TEXT DEFAULT '1.0.0',
  is_online BOOLEAN DEFAULT false,
  last_seen TIMESTAMPTZ,
  config JSONB DEFAULT '{}',
  owner_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(tenant_id, device_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_devices_tenant ON public.devices(tenant_id);
CREATE INDEX IF NOT EXISTS idx_devices_device_id ON public.devices(device_id);
CREATE INDEX IF NOT EXISTS idx_devices_online ON public.devices(is_online);
CREATE INDEX IF NOT EXISTS idx_devices_deleted ON public.devices(deleted_at) WHERE deleted_at IS NULL;

-- Sensor Readings Table
CREATE TABLE IF NOT EXISTS public.sensor_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  gas_ppm FLOAT,
  gas_level TEXT,
  temperature FLOAT,
  humidity FLOAT,
  raw_data JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for sensor readings
CREATE INDEX IF NOT EXISTS idx_sensor_readings_tenant ON public.sensor_readings(tenant_id);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_device ON public.sensor_readings(device_id);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_created ON public.sensor_readings(created_at DESC);

-- ============================================
-- RLS Policies
-- ============================================

ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sensor_readings ENABLE ROW LEVEL SECURITY;

-- Devices: Select policy (tenant isolation)
CREATE POLICY "devices_select_policy" ON public.devices
  FOR SELECT USING (
    tenant_id = (SELECT NULLIF(current_setting('request.jwt.claims', true)::json->>'tenant_id', '')::uuid)
    AND deleted_at IS NULL
  );

-- Devices: Insert policy (admin only)
CREATE POLICY "devices_insert_policy" ON public.devices
  FOR INSERT WITH CHECK (
    tenant_id = (SELECT NULLIF(current_setting('request.jwt.claims', true)::json->>'tenant_id', '')::uuid)
  );

-- Devices: Update policy (admin only)
CREATE POLICY "devices_update_policy" ON public.devices
  FOR UPDATE USING (
    tenant_id = (SELECT NULLIF(current_setting('request.jwt.claims', true)::json->>'tenant_id', '')::uuid)
  );

-- Devices: Service role can do everything (for ESP32 API)
CREATE POLICY "devices_service_policy" ON public.devices
  FOR ALL USING (
    auth.jwt()->>'role' = 'service_role'
  );

-- Sensor readings: Select policy
CREATE POLICY "sensor_readings_select_policy" ON public.sensor_readings
  FOR SELECT USING (
    tenant_id = (SELECT NULLIF(current_setting('request.jwt.claims', true)::json->>'tenant_id', '')::uuid)
  );

-- Sensor readings: Insert policy (service role or device)
CREATE POLICY "sensor_readings_insert_policy" ON public.sensor_readings
  FOR INSERT WITH CHECK (
    auth.jwt()->>'role' = 'service_role'
    OR tenant_id = (SELECT NULLIF(current_setting('request.jwt.claims', true)::json->>'tenant_id', '')::uuid)
  );

-- ============================================
-- Enable Realtime
-- ============================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.devices;
ALTER PUBLICATION supabase_realtime ADD TABLE public.sensor_readings;

-- ============================================
-- Updated_at Trigger
-- ============================================

CREATE OR REPLACE FUNCTION update_devices_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER devices_updated_at_trigger
  BEFORE UPDATE ON public.devices
  FOR EACH ROW
  EXECUTE FUNCTION update_devices_updated_at();

-- ============================================
-- Comments
-- ============================================

COMMENT ON TABLE public.devices IS 'ESP32 IoT devices registry';
COMMENT ON TABLE public.sensor_readings IS 'Sensor data from ESP32 devices';
