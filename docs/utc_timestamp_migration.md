# Moving Active Record timestamps to UTC

Tracking issue: [#1173](https://github.com/joel1di1/martigua2/issues/1173), deferred from the
Rails 8.1 configuration audit ([#1169](https://github.com/joel1di1/martigua2/issues/1169)).

## What changed

`config/application.rb` used to carry:

```ruby
config.time_zone = 'Paris'
config.active_record.default_timezone = :local   # removed
```

With `:local`, Active Record wrote **Paris wall-clock time** into every
`timestamp without time zone` column. The Rails default is `:utc`, and flipping the setting
on its own would not have moved a single byte — it would only have changed how Rails *reads*
what was already there, shifting every historical kickoff, training slot and convocation by
one or two hours. So the setting and the data had to move together, in one commit:

- `db/migrate/20260905120000_convert_timestamps_to_utc.rb` converts the data.
- `config/application.rb` drops the setting.

## Why not a fixed offset

Paris observes DST, so the correction is `+2h` during CEST and `+1h` during CET — a blanket
`UPDATE ... + interval '2 hours'` would corrupt every winter timestamp. The migration goes
through the zone instead, which is DST-aware:

```sql
ALTER TABLE matches
  ALTER COLUMN start_datetime TYPE timestamp
  USING start_datetime AT TIME ZONE 'Europe/Paris' AT TIME ZONE 'UTC';
```

This also handles offsets no one thinks about: the database contains one sentinel row dated
1899, when Paris ran on **Paris Mean Time, UTC+00:09:21**. Postgres gets that right; a fixed
offset would not.

## Scope: this database is shared

Other applications (`eatatjoes_*`, `math_trainer_*`, `resajaaf_*`, `gueulesdebois_*`) keep
their tables in the same `public` schema, which is why they show up in `db/structure.sql`.
They have their own Rails configuration and their own timezone conventions — converting them
here would corrupt *their* data. The migration therefore converts everything in `public`
**except** those prefixes.

The column list is read from the Postgres catalog (`pg_attribute`) at run time rather than being
hard-coded, so a timestamp column added between this migration being written and being deployed
is converted too, instead of being silently left behind in Paris time. The catalog also supplies
each column's exact declared type via `format_type()`, which is restated in the `ALTER COLUMN`:
writing a bare `TYPE timestamp` resets the type modifier and silently downgrades
`timestamp(6)` columns.

## DST edge policy

Two local times are not well-defined in a DST zone. The policy is to accept what Postgres
does, and it is written down here so it is a decision rather than an accident:

| Case | Example (2025) | Postgres resolution |
| --- | --- | --- |
| **Autumn overlap** — local hour occurs twice | `02:30` on 26 Oct | The **second**, standard-time (CET) occurrence → `01:30Z` |
| **Spring gap** — local hour never occurs | `02:30` on 30 Mar | Mapped forward using the pre-transition offset → `01:30Z` (= `03:30` CEST) |

This is acceptable because no handball is played at 02:30 — and, more concretely, **a scan of
every affected column in the production dump found zero rows in either window**:

```
$ psql -d <db> -f dst_check.sql
NOTICE:  scan complete      # no column reported a nonexistent or ambiguous value
```

## Verification against a restored production dump

The suite cannot catch this class of error — it would stay green while the data silently
moved. So the change was verified against a real dump (`latest.dump`, restored by
`bin/new-worktree`), on 115 timestamp columns across 49 tables.

**1. Displayed wall-clock time is unchanged.** A sample of matches, trainings, users and
absences was rendered through Rails before and after the migration. The sample was built to
straddle every DST transition from 2013 to 2027 and to include deep-winter and deep-summer
rows. 129 of 130 lines were byte-identical, e.g.:

```
Match#180 start_datetime=2016-10-30 10:30:00 CET     # the day of the autumn transition
Match#181 start_datetime=2016-10-29 20:30:00 CEST    # the day before
Match#235 start_datetime=2018-03-24 20:30:00 CET     # the day before the spring transition
Match#239 start_datetime=2018-03-25 14:00:00 CEST    # the day of
```

**2. Convocation and daily-mail output is unchanged.** `UserMailer#send_match_invitation` and
`#send_training_invitation` were rendered for 15 real matches and 15 real trainings spanning
CET and CEST, before and after. Subject lines and every rendered time were identical.

**3. The rollback is exact.** `bin/rails db:rollback` was run against the migrated dump and
every one of the 115 columns checksummed back to bit-identical values against a freshly
restored copy of `latest.dump`.

**4. The specs are not vacuous.** `spec/models/timestamp_time_zone_spec.rb` pins both the
rendered wall clock and the value actually stored in the column, for a CET and a CEST date.
Restoring `default_timezone = :local` makes three of its examples fail.

### The one row that does change

`matches#145` holds `1899-12-31 00:00:00`, a spreadsheet-epoch sentinel. Rails used to
*display* it as `1899-12-30 23:09:21`; it now displays `1899-12-31 00:00:00`.

That is a **fix, not a regression**. Under `:local`, Rails parsed the column with Ruby's
`Time.local`, which on this host returns `+01:00` for 1899, while the renderer used TZInfo,
which correctly returns `+00:09:21` — the two disagreed by 9m21s. Reading the column as UTC
removes the disagreement and returns the value stored in the database all along.

This is worth noting beyond the one row, because it shows what `:local` really cost: the
value Rails read depended on the **host's** system timezone, not on the app's configuration.
The same dump read on a server with `TZ=UTC` would have produced different times.

A full scan found exactly one pre-1911 value in the entire database, so the blast radius of
this correction is that single row.

## Reproducing the verification

```bash
bin/new-worktree utc-check 1173-utc-default-timezone   # restores latest.dump
bin/rails runner snapshot.rb > before.txt              # capture displayed times
bin/rails db:migrate
bin/rails runner snapshot.rb > after.txt
diff before.txt after.txt                              # expect only matches#145
```

## Follow-ups deliberately not done here

`DateTime.now` is still used in `Training.send_presence_mail_for_next_week`,
`Section#...` and `User::Attendance#next_week_trainings`. It returns a system-local
`DateTime` rather than a zone-aware time. It is unaffected by `default_timezone` — that
setting only governs how columns are read and written — and comparisons against Active
Record datetimes work on absolute instants, so it is correct today. It should still become
`Time.zone.now`, but that is a separate change.
