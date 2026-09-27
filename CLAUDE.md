# Martigua2 - Sports Club Management Application

## Project Overview
Martigua2 is a Ruby on Rails application for managing sports clubs, particularly handball clubs. It handles teams, matches, training sessions, player management, and club administration.

## Technology Stack
- **Backend**: Ruby on Rails (latest guidelines and conventions)
- **Database**: PostgreSQL
- **Testing**: RSpec with FactoryBot, Faker, Timecop
- **Code Quality**: RuboCop for linting

For our shared Rails/Tailwind/Slim/RSpec/Stimulus conventions, read `~/.claude/RAILS-HOUSE-STYLE.md` before writing code.

## Key Models & Relationships
- **Club** → has many Sections
- **Section** → belongs to Club, has many Users (through Participations), Teams, Trainings, Matches
- **User** → has many Sections (through Participations), can be Player/Coach
- **Season** → time-bound context for participations and activities
- **Match** → games between teams
- **Training** → practice sessions for sections
- **Team** → groups within sections for competitions

## Important Commands
- **Tests**: `bin/rspec`
- **Linting**: `bin/rubocop`
- **Database**: Standard Rails migration commands using `bin/rails`
