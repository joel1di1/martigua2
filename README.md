[![Maintainability](https://api.codeclimate.com/v1/badges/f023a142fab9d17c0d7b/maintainability)](https://codeclimate.com/github/joel1di1/martigua2/maintainability)

[![Test Coverage](https://api.codeclimate.com/v1/badges/f023a142fab9d17c0d7b/test_coverage)](https://codeclimate.com/github/joel1di1/martigua2/test_coverage)

Martigua2
=========

Code of the amazing site www.martigua.org

Contributing
--

If you make improvements to this application, please share with others.

-   Fork the project on GitHub.
-   Make your feature addition or bug fix.
-   Commit with Git.
-   Send the author a pull request.

If you add functionality to this application, create an alternative
implementation, or build an application that is similar, please contact
me and I’ll add a note to the README so that others can find your work.

Dev Setup
--

1. sur mac c'est quand même plus facile
2. Install homebrew : https://brew.sh/
3. Install rvm or rbenv
4. git clone ...
5. bundle
6. docker-compose up
7. rails db:reset
8. rspec


Restore production database locally
--

```bash
heroku pg:backups:capture
heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -p 54321 -U postgres -d martigua2_development latest.dump
bin/rails db:environment:set RAILS_ENV=development
bin/rails db:migrate
```


Working on several branches in parallel
--

`bin/new-worktree <name>` creates a git worktree with its own Postgres database, its own
Redis database index and its own port, so you can run several checkouts side by side against
the single shared docker-compose stack.

```bash
bin/new-worktree ma-feature      # -> ../martigua2-ma_feature, branch ma-feature
cd ../martigua2-ma_feature
bin/dev                          # http://localhost:3010
```

Each worktree gets a slot (1 to 7), which fixes its settings:

| slot | database | redis db (dev / test) | port |
|------|----------|-----------------------|------|
| main | `martigua2_development` | 0 / 1 | 3000 |
| 1    | `martigua2_<name>_development` | 2 / 3 | 3010 |
| 2    | `martigua2_<name>_development` | 4 / 5 | 3020 |

The script copies the gitignored files a fresh checkout is missing (`.env.local`, `.envrc`,
`config/master.key`), appends the slot settings to `.env.local`, writes `.env.test.local`
(dotenv ignores `.env.local` in the test env), and restores `latest.dump` into the new
database when that file is present at the root of the main checkout.

`bin/rm-worktree <name>` tears it down: it drops the databases, flushes the redis indexes and
removes the worktree, refusing to run while there is uncommitted work unless given `--force`.
The branch itself is left alone.


License
--

MIT
