# Martigua2

[![CI](https://github.com/joel1di1/martigua2/actions/workflows/main.yml/badge.svg)](https://github.com/joel1di1/martigua2/actions/workflows/main.yml)

The app behind [www.martigua.org](https://www.martigua.org): it manages handball clubs, their
sections, teams, players, trainings and matches.

Rails 8 on Ruby (version in `.ruby-version`), PostgreSQL, Slim, Tailwind, Hotwire
(Turbo + Stimulus), Solid Queue / Cache / Cable, RSpec. Conventions and testing rules are
in [`CLAUDE.md`](CLAUDE.md): read it before contributing.

## Setup

Prerequisites: the Ruby version from `.ruby-version`, Docker, libvips (`brew install vips`)
and Chrome for the system specs.

```bash
docker compose up -d   # Postgres on localhost:54321
bin/setup              # bundle install, db:prepare, then starts bin/dev
```

## Daily commands

| Command | What it does |
|---------|--------------|
| `bin/dev` | Rails server and Tailwind watcher, on http://localhost:3000 |
| `bin/rspec` | Test suite (`bin/parallel_rspec spec` to use every CPU) |
| `bin/rubocop` | Lint (`-A` to autocorrect) |
| `bundle exec i18n-tasks missing` / `unused` / `check-normalized` | i18n checks, also run in CI |

## Restore the production database locally

```bash
heroku pg:backups:capture
heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -p 54321 -U postgres -d martigua2_development latest.dump
bin/rails db:environment:set RAILS_ENV=development
bin/rails db:migrate
```

## Several branches in parallel

```bash
bin/new-worktree my-feature   # ../martigua2-my_feature, branch my-feature
cd ../martigua2-my_feature
bin/dev                       # http://localhost:3010
bin/rm-worktree my-feature    # drops its databases and removes the worktree
```

Each worktree gets its own databases and port against the shared docker-compose stack, and
starts from `latest.dump` when that file is at the root of the main checkout. Details are
at the top of `bin/new-worktree`.

## Deployment

Production runs on Heroku: a `web` dyno (Puma) and a `worker` dyno (Solid Queue), with
migrations run on release (see `Procfile`).

## Agent workflow

Issues and pull requests can be handed to the coding agent with labels: `agent:refine!` on
an issue to refine it, `agent:dev!` on an issue to implement it or on a pull request to address
its review. See `.github/workflows/agent.yml` and `config/managed_agents/`.

## License

MIT
