# Martigua2 - Sports Club Management Application

## Project Overview
Martigua2 is a Ruby on Rails application for managing sports clubs, particularly handball clubs. It handles teams, matches, training sessions, player management, and club administration.

## Technology Stack
- **Backend**: Ruby on Rails (latest guidelines and conventions)
- **Database**: PostgreSQL (assumed from Rails conventions)
- **Frontend**: 
  - **Template Engine**: Slim (preferred) with `div class="..."` syntax for Tailwind CSS
  - **CSS Framework**: Tailwind CSS (migrating from Bootstrap)
  - **JavaScript**: Stimulus controllers (prefer https://www.stimulus-components.com/ over custom controllers)
- **Testing**: RSpec with FactoryBot
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

### Button Styling Standards
- **Primary buttons**: `inline-flex items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-xs hover:bg-indigo-700 focus:outline-hidden focus:ring-3 focus:ring-indigo-500 focus:ring-offset-2`
- **Danger buttons**: `inline-flex items-center rounded-md border border-transparent bg-red-600 px-4 py-2 text-sm font-medium text-white shadow-xs hover:bg-red-700 focus:outline-hidden focus:ring-3 focus:ring-red-500 focus:ring-offset-2`
- **Secondary buttons**: Use existing indigo-100 with indigo-700 text patterns seen in the codebase

### Code Style
- Follow latest Rails guidelines and conventions
- Use RuboCop for code formatting
- Write tests for new features
- Follow existing patterns in the codebase

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

## Common Patterns
- Use `current_section` and `current_user` in controllers and views
- Participations link users to sections with roles (PLAYER, COACH)  
- Seasons provide temporal context for most activities
- Form helpers use SimpleForm with Tailwind styling
- Stimulus controllers handle interactive JavaScript behavior (prefer stimulus-components.com)

## Testing
- Model tests in `spec/models/`
- Request tests in `spec/requests/`
- Feature tests in `spec/features/` using Capybara
- Use FactoryBot for test data creation
- Follow existing test patterns and naming conventions
- Run tests with `bin/rspec`

## File Structure Notes
- Views: Prefer `.slim` files in `app/views/`
- Models: Standard Rails structure in `app/models/`
- Controllers: RESTful controllers in `app/controllers/`
- JavaScript: Stimulus controllers in `app/javascript/controllers/` (prefer stimulus-components.com)
- Stylesheets: Tailwind configuration in `app/assets/stylesheets/`