# frozen_string_literal: true

RSpec.describe SentrySpanDeduplicator do
  def span(operation:, description:)
    { op: operation, description: description }
  end

  let(:solid_cache_query) do
    'SELECT "solid_cache_entries"."key", "solid_cache_entries"."value" FROM "solid_cache_entries" ' \
      'WHERE "solid_cache_entries"."key_hash" IN ($1)'
  end

  describe '.call' do
    it 'keeps only the first occurrence of a known noisy span pattern' do
      spans = [
        span(operation: 'http.client', description: 'GET https://example.com'),
        span(operation: 'db.sql.active_record', description: solid_cache_query),
        span(operation: 'db.sql.active_record', description: solid_cache_query),
        span(operation: 'db.sql.active_record', description: solid_cache_query)
      ]

      result = SentrySpanDeduplicator.call(spans)

      solid_cache_spans = result.select { |s| s[:description] == solid_cache_query }
      expect(solid_cache_spans.size).to eq(1)
      expect(result).to include(span(operation: 'http.client', description: 'GET https://example.com'))
    end

    it 'leaves unrelated repeated spans untouched so other N+1 detection keeps working' do
      repeated_query = 'SELECT "users".* FROM "users" WHERE "users"."section_id" = $1'
      spans = Array.new(5) { span(operation: 'db.sql.active_record', description: repeated_query) }

      result = SentrySpanDeduplicator.call(spans)

      expect(result.size).to eq(5)
    end

    it 'is a no-op when there are no noisy spans' do
      spans = [span(operation: 'http.client', description: 'GET https://example.com')]

      expect(SentrySpanDeduplicator.call(spans)).to eq(spans)
    end

    it 'handles an empty span list' do
      expect(SentrySpanDeduplicator.call([])).to eq([])
    end
  end
end
