# Martigua2 - Sports Club Management Application

## Project Overview
Martigua2 is a Ruby on Rails application for managing sports clubs, particularly handball clubs. It handles teams, matches, training sessions, player management, and club administration.

## Technology Stack
- **Backend**: Ruby on Rails (latest guidelines and conventions)
- **Database**: PostgreSQL
- **Frontend**: 
  - **Template Engine**: Slim (preferred) with `div class="..."` syntax for Tailwind CSS
  - **CSS Framework**: Tailwind CSS (migrating from Bootstrap)
  - **JavaScript**: Stimulus controllers (prefer https://www.stimulus-components.com/ over custom controllers)
- **Testing**: RSpec with FactoryBot, Faker, Timecop
- **Code Quality**: RuboCop for linting

## Development Preferences

### Template Files
- **Preferred**: Slim templates with `div class="..."` syntax for easy Tailwind CSS class copying
- **Legacy**: Some HAML files exist but should be migrated to Slim when touched
- **CSS Classes**: Use Tailwind CSS classes, avoid Bootstrap classes

### Stimulus Controllers
- **Preferred approach**: Use components from https://www.stimulus-components.com/
- **Avoid**: Creating new custom Stimulus controllers when existing components can solve the problem
- **Research first**: Check stimulus-components.com before writing custom JavaScript

### Code Style
- Follow latest Rails guidelines and conventions
- Use RuboCop for code formatting
- Write tests for new features
- Follow existing patterns in the codebase

### Test Driven Development
When developping a feature, write the tests first.
For user facing feature, use system test to test nominal cases.
Add unit tests for new methods created on model or services layers.
Don't test trivial methods.
Before commits, run rubocop.

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

## Development Guidelines
1. **Follow latest Rails guidelines** - use current Rails conventions and best practices
2. **Always run tests** when making changes to ensure functionality works
3. **Follow existing code patterns** - look at similar implementations before creating new features  
4. **Use proper Tailwind classes** - avoid Bootstrap classes, migrate when found
5. **Prefer Stimulus Components** - check https://www.stimulus-components.com/ before creating custom controllers
6. **Write tests** for new functionality using RSpec and FactoryBot patterns
7. **Prefer editing existing files** over creating new ones when possible
8. **Use Slim template syntax** with `div class="..."` for easy Tailwind integration
