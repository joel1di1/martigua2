# Code Quality TODO

Audit date: 2026-07-03. Each task is self-contained so it can be delegated to another dev.

Statuses: `todo` | `in_progress` | `done` | `wont_do`

---

## P1 — Authorization gap: any signed-in user can modify other clubs' data (IDOR)

- **Status**: done — delivered as five PRs. PR 1 (global `verify_user_member_of_section` gate + shared request-spec example): `security/section-membership-gate` — merged (#1100). PR 2 (scope `Championship`/`Match` finders through `current_section`, `ApplicationController#verify_section_ownership!`, hardened `MatchesController#create`/`#update` against `championship_id` body-param spoofing): `security/scope-championship-match-finders` — merged (#1101). PR 3 (selection/day/training family; `ApplicationController#verify_day_ownership!` since `Day` belongs to a season-wide `Calendar` rather than a section; `TrainingPresencesController` and `MatchesController#selection` scoping; widened `catch404` to `json`/`js`): `security/scope-selection-day-training-finders` — merged (#1102). PR 4 (users/absences/participations/messages family: `UsersController#find_user_by_id`/`#destroy` group scoping — closed the account-takeover-via-password-reset vector where any coach could read/edit another club's member email/phone; `AbsencesController`, `MessagesController#set_channel`, `ParticipationsRenewalController`): `security/scope-users-absences-messages-finders` — merged (#1103). PR 5 (final cleanup): removed the top-level `resources :days`/`resources :championships` routes in `config/routes.rb` — confirmed unused (grepped for helper usage across app/lib/spec) and actively dangerous, since hitting them left `current_section` blank, which made `verify_user_member_of_section` *and* `verify_section_ownership!`/`verify_day_ownership!` no-op (both early-return when `current_section.blank?`), letting any signed-in user edit/create days and championships belonging to any club; scoped the previously self-referential `UsersController#match_availabilities`/`#training_presences` match/training ids via new `Training.of_sections`/`Championship.of_sections` scopes; removed the unused Pundit gem (`Gemfile`, `Gemfile.lock`, `app/policies/`, `include Pundit::Authorization`) since zero policies or `authorize` calls existed. Branch: `security/finish-p1-routes-cleanup-remove-pundit`.
- **Priority**: 1

**Details**: Pundit is in the Gemfile and included in `ApplicationController`, but there are zero policies (`app/policies/` only contains `application_policy.rb.keep`) and zero `authorize` calls. Authorization is ad hoc: only 5 controllers use `verify_user_member_of_section`. Example: `ChampionshipsController#update` / `#update_group` load the record with `Championship.find(params.expect(:id))` and never check that the current user belongs to the owning section — any signed-in user from any club can edit another club's championships. Same pattern likely in other controllers (matches, trainings, groups…).

**Expected work**:
1. Audit every controller action that loads a record by `params[:id]` and check whether membership/role is verified.
2. Pick one strategy: adopt Pundit properly (policies + `authorize` + `verify_authorized`) OR scope all finders through `current_section` / `current_user` associations.
3. Add request specs asserting a user from another section gets 403/404.

---

## P2 — Bug: `Season.current` cached forever per Puma thread

- **Status**: todo
- **Priority**: 2

**Details**: `app/models/season.rb:23` — `Thread.current[:current_season] ||= _current` is never invalidated. Puma threads live for weeks, so when the season rolls over (July 31), production keeps serving the old season until a restart. `Season.current` is used in 40+ places, including scopes and `Championship#after_initialize`.

**Expected work**: Replace the thread-local memoization with one of: `Current.season` (reset per request), `Rails.cache.fetch('season/current', expires_in: 1.hour)`, or a cache keyed by `Date.current`. Add a spec proving a rollover is picked up without restart.

---

## P3 — Bug: `User#last_time_duty` always returns nil

- **Status**: todo
- **Priority**: 3

**Details**: `app/models/user.rb:155` — `duty_tasks.where(name: task_key).order(name: :desc)`. Tasks are created with `key: task_key` (`realised_task!`); the `name` column holds the French label (see `DutyTask::TASKS`), so the `where` never matches. Ordering by `name: :desc` is also wrong — should be `realised_at: :desc`. If this feeds duty-rotation fairness, it silently returns nil for everyone.

**Expected work**: Change to `duty_tasks.where(key: task_key).order(realised_at: :desc).first&.realised_at`. Add a unit spec. Check callers to see whether the broken behavior was compensated elsewhere. Also simplify `realised_task!` (`duty_tasks << DutyTask.create!(...)` — the `<<` is redundant since `create!` already sets `user`).

---

## P4 — Bug: `Match#selections(team)` shadows the `has_many :selections` association

- **Status**: todo
- **Priority**: 4

**Details**: `app/models/match.rb:111` defines `def selections(team)` while the model also declares `has_many :selections`. Any call to `match.selections` without an argument raises `ArgumentError`.

**Expected work**: Rename the method to `selections_for(team)`, update callers (views/controllers), add a spec that `match.selections` returns the association.

---

## P5 — Bug: `Match.of_next_7_days` returns the current week, not the next 7 days

- **Status**: todo
- **Priority**: 5

**Details**: `app/models/match.rb:101` — computes `date.at_beginning_of_week..end_of_week`, i.e. the *calendar week of `date`*, not `date..date + 7.days`. Called from availability-mail logic; a Sunday run would miss next weekend's matches.

**Expected work**: Decide intended semantics with product owner (calendar week vs rolling 7 days), then fix either the name or the implementation, plus specs with Timecop around week boundaries.

---

## P6 — Security: token auth via URL query params leaks tokens into logs

- **Status**: todo
- **Priority**: 6

**Details**: `app/controllers/application_controller.rb:130` — `authenticate_user_from_token!` signs users in from `?user_email=...&user_token=...`. Tokens end up in server logs (our own `request_string` logs the full query string), browser history, and Referer headers. Tokens never expire and never rotate.

**Expected work**: Replace with signed expiring tokens (`Rails.application.message_verifier` or Rails 8 `generates_token_for`) for email links; filter `user_token` from logs in the meantime (`config.filter_parameters`).

---

## P7 — Security: replace the two `permit!` calls (Brakeman warnings)

- **Status**: todo
- **Priority**: 7

**Details**: Brakeman flags Mass Assignment at `app/controllers/sections_controller.rb:50` and `app/controllers/championships_controller.rb:79` (`params.require(:team_links).permit!`). `permit!` allows arbitrary keys.

**Expected work**: Permit explicit keys/shapes for `team_links` (hash of ffhb_team_id → team_id) and the sections case. Brakeman should then report 0 warnings; add Brakeman to CI if not already there.

---

## P8 — N+1: `PrefetchMatchData#build_availability_counts_hash` queries inside a loop

- **Status**: todo
- **Priority**: 8

**Details**: `app/controllers/concerns/prefetch_match_data.rb:74` — for each match it runs `match.match_availabilities.where(available: true).pluck(:user_id)` and `match.aways.where(...).count` (which itself joins users/participations/absences). On a section dashboard with 20 upcooming matches that's ~40 extra queries, defeating the purpose of the "prefetch" concern.

**Expected work**: Compute available user ids per match from a single grouped query (data is already mostly fetched in `precompute_match_availability_counts`), and compute aways from the already-fetched absences. Assert query count in a spec (or add `bullet`/`rspec-sqlimit`).

---

## P9 — Refactor: extract FFHB sync/import into service objects

- **Status**: todo
- **Priority**: 9

**Details**: The FFHB integration is the complexity hotspot hidden by `.rubocop_todo.yml` (AbcSize max 64 vs default 17):
- `Championship#sync_new_matches!` (~70 lines, app/models/championship.rb:182)
- `Match#ffhb_sync!` (app/models/match.rb:119)
- `ChampionshipsController#new` — 35-line cascade of `return if` building FFHB form options
- `ChampionshipsController#create` — two unrelated creation flows (FFHB import vs manual) in one nested if/else, with duplicated redirect blocks

**Expected work**: Create `app/services/ffhb/` service objects (e.g. `Ffhb::ChampionshipSync`, `Ffhb::MatchSync`, `Ffhb::ImportForm`). Split FFHB import into its own controller/action to remove the branching. Lower the Metrics ceilings in `.rubocop_todo.yml` afterwards so the debt can't regrow.

---

## P10 — Refactor: unify availability/absence counting logic (3 divergent copies)

- **Status**: todo
- **Priority**: 10

**Details**: The "who is available / away for a match" logic exists three times with subtle differences that can disagree:
- `Match#availables` / `#aways` / `#not_availables` (app/models/match.rb:52-92)
- `PrefetchMatchData` concern (app/controllers/concerns/prefetch_match_data.rb)
- `User#absent_for?` / `#next_7_days_matches` (app/models/user.rb:199, 133)

E.g. boundary handling of `day.period_start_date`/`period_end_date` differs between copies.

**Expected work**: Extract a single query/counter object (e.g. `MatchAvailabilitySummary`) used by all three call sites, with specs covering the boundary cases (absence overlapping match start only, end only, whole period).

---

## P11 — Refactor: slim down the `User` god object

- **Status**: todo
- **Priority**: 11

**Details**: `app/models/user.rb` (226 lines) mixes training presence, match availability, absences, duty tasks, channel read-tracking. Also: leading-underscore methods called publicly (`_set_presence_for!`, `_confirm_presence!`), `User#read?` is a predicate with a write side effect (`find_or_create_by` on read — breaks on read replicas), and `super_admin?` is hardcoded `id == 1` (fragile; one re-seed away from privilege escalation).

**Expected work**:
1. Extract concerns (`User::Attendance`, `User::Availability`) or move logic to owning models.
2. Make underscore methods private behind proper public APIs.
3. Make `read?` read-only; create the row in `read!` only.
4. Replace `id == 1` with a `super_admin` boolean column or role.

---

## P12 — Convention: migrate remaining HAML views to Slim

- **Status**: todo
- **Priority**: 12

**Details**: 47 HAML files remain vs 75 Slim (plus 16 ERB). Project convention (CLAUDE.md) is Slim with `div class="..."` for Tailwind. Mixing three template engines adds friction.

**Expected work**: Migrate opportunistically when touching a view, or batch-convert low-risk views (index/show pages) with visual check. Remove `haml-rails` from the Gemfile once done.

---

## P13 — Tooling: add bullet, rubocop-performance, strong_migrations

- **Status**: todo
- **Priority**: 13

**Details**: Three cheap guardrails missing from the Gemfile:
- `bullet` (dev/test) — catches N+1s automatically; this codebase's main perf risk.
- `rubocop-performance` — every other rubocop plugin is already enabled.
- `strong_migrations` — PostgreSQL app with live data; prevents blocking migrations.

**Expected work**: Add gems, configure (bullet raise in test), fix whatever they surface, wire into CI.

---

## P14 — Repo hygiene: remove personal/data files from the repository

- **Status**: todo
- **Priority**: 14

**Details**: Repo root contains `latest.dump` (a DB dump — may hold real member PII; check git history), `homeexchange_islande_2026.csv`, `vacances_islande_2026.md`, `story_map.xmind`, `CI-DEBUG-README.md`.

**Expected work**: Delete/relocate the files, add patterns to `.gitignore` (`*.dump`). If `latest.dump` with real data was ever committed, consider history rewrite (`git filter-repo`) and rotating any secrets it contains.

---

## P15 — Cleanup: small conventions fixes

- **Status**: todo
- **Priority**: 15

**Details**: Low-risk one-liners, can be a single PR:
- `ApplicationController` line 4: remove `extend ActiveSupport::Concern` (meant for modules, meaningless on a class).
- `Match#meeting_datetime`: `start_datetime&.send(:-, 1.hour)` → `start_datetime && start_datetime - 1.hour`.
- `ChampionshipsController#create`: dedupe the two identical `redirect_with` blocks.
- `User#present_for!` / `not_present_for!` / `not_available_for!`: extract the shared "normalize arg to array" helper (`Array.wrap`).
