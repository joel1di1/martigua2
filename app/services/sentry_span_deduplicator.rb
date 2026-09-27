# frozen_string_literal: true

# Strips repeated occurrences of known low-value, high-volume spans from a Sentry
# transaction before it is sent, so Sentry's automated N+1 detector does not flag them.
#
# This only suppresses the specific query/cache patterns listed in
# NOISY_DESCRIPTION_PATTERNS. Every other repeated span is left untouched, so N+1
# detection keeps working normally for genuinely new violations.
#
# Background: SolidCache-backed `Rails.cache.fetch`/`.read` calls issue one
# `solid_cache_entries` lookup per key. Doing this once per URL inside FfhbService
# (see FfhbSyncJob) is expected usage, not a bug: each read is a few ms, and the
# job's actual cost is the external HTTP calls it wraps (avg ~500ms each). See
# Sentry issue MARTIGUA2-CA for the triage notes.
class SentrySpanDeduplicator
  NOISY_DESCRIPTION_PATTERNS = [
    /FROM\s+"solid_cache_entries"/i
  ].freeze

  class << self
    def call(spans)
      seen_noisy_descriptions = Hash.new(false)

      spans.reject do |span|
        description = span[:description].to_s
        next false unless noisy?(description)

        already_seen = seen_noisy_descriptions[description]
        seen_noisy_descriptions[description] = true
        already_seen
      end
    end

    private

    def noisy?(description)
      NOISY_DESCRIPTION_PATTERNS.any? { |pattern| pattern.match?(description) }
    end
  end
end
