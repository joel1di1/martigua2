# frozen_string_literal: true

# Moves every martigua2-owned `timestamp without time zone` column from Paris wall-clock
# time to UTC, so that `config.active_record.default_timezone` can be dropped to the Rails
# default of :utc in the same commit.
#
# Until now the app ran with `default_timezone = :local` and `time_zone = 'Paris'`, so
# Active Record wrote Paris wall-clock time into these columns. Flipping the setting alone
# would not move any data -- it would only change how Rails *reads* what is already there,
# silently shifting every historical match kickoff, training slot and convocation by one or
# two hours. The data has to move with the setting, which is what this migration does.
#
# The conversion goes through `AT TIME ZONE 'Europe/Paris'`, never a fixed offset: Paris is
# a DST zone, so the correction is +2h during CEST and +1h during CET -- and +00:09:21 for
# the pre-1911 Paris Mean Time values that a couple of sentinel rows still carry.
#
# DST edge policy (see docs/utc_timestamp_migration.md): Postgres resolves the autumn hour
# that occurs twice to its second, standard-time (CET) occurrence, and maps the spring hour
# that never occurs forward using the pre-transition offset. Both are accepted as-is -- no
# handball is played at 02:30, and a scan of the production dump found zero rows in either
# window.
#
# NOTE: this migration is invisible in db/structure.sql. The column types do not change
# (`timestamp without time zone` before and after); only the values inside them move.
class ConvertTimestampsToUtc < ActiveRecord::Migration[8.1]
  TIME_ZONE = 'Europe/Paris'

  # This Postgres database is shared with other applications, whose tables live in the same
  # `public` schema and therefore show up in db/structure.sql. They have their own Rails
  # configuration and their own timezone conventions -- converting them here would corrupt
  # *their* data. Everything else in `public` belongs to martigua2 and must be converted.
  FOREIGN_APP_PREFIXES = %w[eatatjoes_ math_trainer_ resajaaf_ gueulesdebois_].freeze

  def up
    convert(from: TIME_ZONE, to: 'UTC')
  end

  def down
    convert(from: 'UTC', to: TIME_ZONE)
  end

  private

  # Rewrites each table once, converting all of its timestamp columns in a single
  # ALTER TABLE. Reading the columns from the catalog rather than hard-coding them means a
  # timestamp column added between this migration being written and being deployed is
  # converted too, instead of being silently left behind in Paris time.
  def convert(from:, to:)
    columns_by_table.each do |table, columns|
      changes = columns.map do |(column, type)|
        quoted = connection.quote_column_name(column)
        # Restate the column's *exact* current type. Writing a bare `timestamp` here would
        # work, but it resets the type modifier and silently rewrites `timestamp(6)` columns
        # as `timestamp`, producing a spurious db/structure.sql diff on 39 columns.
        "ALTER COLUMN #{quoted} TYPE #{type} " \
          "USING #{quoted} AT TIME ZONE #{connection.quote(from)} AT TIME ZONE #{connection.quote(to)}"
      end

      say "#{table}: #{columns.map(&:first).join(', ')}", true
      # Rewrites the table under an ACCESS EXCLUSIVE lock. Accepted deliberately: the
      # largest table here is ~43k rows, and the migration has to be atomic with respect to
      # the config flip that ships alongside it -- a partially converted database serves
      # wrong times.
      safety_assured do
        connection.execute "ALTER TABLE #{connection.quote_table_name(table)} #{changes.join(', ')}"
      end
    end
  end

  def columns_by_table
    not_foreign = FOREIGN_APP_PREFIXES.map do |prefix|
      "c.relname NOT LIKE #{connection.quote("#{prefix}%")}"
    end

    # format_type() renders the column's declared type with its modifier, so a
    # `timestamp(6) without time zone` column comes back as exactly that and is put back
    # unchanged.
    rows = connection.select_rows(<<~SQL.squish)
      SELECT c.relname, a.attname, format_type(a.atttypid, a.atttypmod)
      FROM pg_attribute a
      JOIN pg_class c ON c.oid = a.attrelid
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = #{connection.quote(connection.current_schema)}
        AND c.relkind = 'r'
        AND a.attnum > 0
        AND NOT a.attisdropped
        AND a.atttypid = 'timestamp without time zone'::regtype
        AND #{not_foreign.join(' AND ')}
      ORDER BY c.relname, a.attnum
    SQL

    rows.group_by(&:first)
        .transform_values { |triples| triples.map { |(_table, column, type)| [column, type] } }
  end
end
