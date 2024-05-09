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
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d martigua2_development latest.dump
bin/rails db:environment:set RAILS_ENV=development
bin/rails db:migrate
```


License
--

MIT
