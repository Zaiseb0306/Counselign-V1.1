-- Add counselor_remarks column to appointments table
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS counselor_remarks TEXT DEFAULT NULL;

-- Optional: Update existing completed appointments with a default remark if needed
-- UPDATE appointments SET counselor_remarks = 'Session completed successfully' WHERE status = 'completed' AND (counselor_remarks IS NULL OR counselor_remarks = '');