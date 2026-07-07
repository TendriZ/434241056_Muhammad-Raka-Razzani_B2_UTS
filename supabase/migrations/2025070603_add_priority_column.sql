-- Add priority column to tickets table
ALTER TABLE tickets
ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'medium';

-- Add comment for documentation
COMMENT ON COLUMN tickets.priority IS 'Ticket priority: low, medium, or high';