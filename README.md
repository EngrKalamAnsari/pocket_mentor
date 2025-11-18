# Pocket Mentor

A Rails 8 application that generates personalized AI-powered lessons using the Groq API. Users can create custom lessons on various topics at different difficulty levels (beginner, intermediate, advanced).

## Features

- 🔐 **User Authentication**: Secure user registration and authentication using Devise
- 🤖 **AI-Powered Lessons**: Generate personalized lessons using Groq's LLM API
- 📚 **Lesson Management**: Create, view, and manage your lessons
- 🎯 **Authorization**: Role-based access control with CanCanCan
- 📊 **Code Coverage**: Test coverage tracking with SimpleCov
- 🔒 **Security**: Automated security scanning with Brakeman
- ✅ **CI/CD**: Automated testing and linting via GitHub Actions

## Tech Stack

- **Framework**: Rails 8.0.4
- **Ruby**: 3.4.4
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Authorization**: CanCanCan
- **AI Integration**: Groq API (via Faraday)
- **Testing**: RSpec, FactoryBot, WebMock
- **Code Quality**: RuboCop, Brakeman
- **Code Coverage**: SimpleCov
- **Styling**: Tailwind CSS
- **Asset Pipeline**: Propshaft

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.4.4** (use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/))
- **PostgreSQL** (9.3 or higher)
- **Bundler** gem
- **Node.js** (for asset compilation)
- **Git**

## Local Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd pocket_mentor
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies (if any)
# Note: This project uses importmap, so no npm/yarn install needed
```

### 3. Database Setup

```bash
# Create and setup the database
bin/rails db:create
bin/rails db:migrate

# (Optional) Seed the database
bin/rails db:seed
```

### 4. Environment Variables

Create a `.env` file in the root directory (or use `dotenv-rails`):

```bash
# Required: Groq API Key
GROQ_API_KEY=your_groq_api_key_here

# Optional: Custom Groq model (defaults to 'llama-3.1-8b-instant')
GROQ_MODEL=llama-3.1-8b-instant
```

**Getting a Groq API Key:**
1. Visit [console.groq.com](https://console.groq.com)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key to your `.env` file

### 5. Start the Server

```bash
# Start the Rails server
bin/rails server

# Or use the Procfile.dev for development with all services
bin/dev
```

The application will be available at `http://localhost:3000`

## Running Tests

### Run All Tests

```bash
bundle exec rspec
```

### Run Specific Test Files

```bash
# Run a specific test file
bundle exec rspec spec/models/lesson_spec.rb

# Run tests for a specific directory
bundle exec rspec spec/models/
```

### View Test Coverage

After running tests, coverage reports are generated in the `coverage/` directory:

```bash
# Open the coverage report
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
```

The coverage report shows:
- Overall coverage percentage
- Coverage by file
- Coverage grouped by Services and Jobs

## Code Quality

### Linting with RuboCop

```bash
# Check for style violations
bundle exec rubocop

# Auto-fix violations where possible
bundle exec rubocop -a

# Check specific file
bundle exec rubocop app/models/lesson.rb
```

### Security Scanning with Brakeman

```bash
# Run security scan
bin/brakeman

# Run with no pager (useful for CI)
bin/brakeman --no-pager
```

## Project Structure

```
pocket_mentor/
├── app/
│   ├── controllers/       # Application controllers
│   │   ├── lessons_controller.rb
│   │   └── application_controller.rb
│   ├── models/            # ActiveRecord models
│   │   ├── user.rb
│   │   ├── lesson.rb
│   │   └── ability.rb     # CanCanCan authorization
│   ├── services/          # Business logic services
│   │   ├── generate_lesson_service.rb
│   │   └── groq_client.rb
│   └── views/            # ERB templates
├── config/                # Application configuration
├── db/                    # Database migrations and schema
├── spec/                  # RSpec test files
│   ├── models/
│   ├── controllers/
│   ├── services/
│   └── factories/         # FactoryBot factories
└── coverage/             # SimpleCov coverage reports
```

## Key Components

### Services

- **GenerateLessonService**: Orchestrates lesson generation, handles validation, AI API calls, JSON parsing, and persistence
- **GroqClient**: Handles communication with Groq API, builds prompts, and parses responses

### Models

- **User**: Devise-managed user model with email/password authentication
- **Lesson**: Belongs to user, contains topic, level, content, and metadata (quiz)
- **Ability**: CanCanCan ability definitions for authorization

## Database Schema

### Users Table
- Email (unique, indexed)
- Encrypted password
- Devise modules: recoverable, rememberable, trackable, confirmable, lockable

### Lessons Table
- `topic` (string, max 150 chars)
- `level` (enum: beginner, intermediate, advanced)
- `content` (text)
- `metadata` (jsonb, stores quiz data)
- `user_id` (foreign key, indexed)
- `created_at`, `updated_at` (timestamps, indexed)

## CI/CD

The project includes GitHub Actions workflows for:

1. **Security Scanning**: Brakeman static analysis
2. **JavaScript Audit**: Importmap dependency scanning
3. **Linting**: RuboCop style checking
4. **Testing**: Full RSpec test suite with PostgreSQL

Workflows run on:
- Pull requests
- Pushes to `main` branch

## Development Tips

### Using the Rails Console

```bash
bin/rails console

# Create a test user
user = User.create!(email: 'test@example.com', password: 'password123')

# Generate a lesson
lesson = user.lessons.build(topic: 'Ruby Basics', level: 'beginner')
GenerateLessonService.call(lesson)
```

### Debugging

The project includes the `debug` gem for debugging:

```ruby
# Add breakpoints in your code
binding.break
```

### FactoryBot Usage

```ruby
# In tests
user = create(:user)
lesson = create(:lesson, user: user, topic: 'Rails', level: 'intermediate')
```

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Write/update tests
4. Ensure all tests pass: `bundle exec rspec`
5. Run RuboCop: `bundle exec rubocop`
6. Ensure code coverage is maintained
7. Submit a pull request

## License

[Add your license here]

## Support

For issues and questions, please open an issue in the repository.
