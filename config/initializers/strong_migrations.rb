# frozen_string_literal: true

# Only check migrations created after the gem was introduced.
StrongMigrations.start_after = 20_260_619_094_233

# Longer statement timeouts are fine for this app's small tables; keep the
# gem defaults for lock timeouts.
