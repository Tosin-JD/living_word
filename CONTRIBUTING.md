# Contributing to Living Word

First off, thank you for considering contributing to Living Word! It's people like you that make Living Word such a great tool for Bible study.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:

- Be respectful and inclusive
- Welcome newcomers
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the problem
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Device and OS version**
- **App version**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** - why would this be useful?
- **Proposed solution** or approach
- **Alternatives considered**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Ensure the test suite passes: `flutter test`
4. Make sure your code follows the style guidelines
5. Write a clear commit message
6. Open a Pull Request with a comprehensive description

## Development Setup

1. Install Flutter SDK (3.0+)
2. Clone the repository
3. Run `flutter pub get`
4. Run `flutter pub run build_runner build`
5. Run the app: `flutter run`

## Style Guidelines

### Dart Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter format` before committing
- Maximum line length: 80 characters
- Use meaningful variable names

### Git Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests

### Testing

- Write tests for new features
- Maintain or improve code coverage
- Run `flutter test` before submitting PR

## Project Structure

Follow the existing project structure:

- `lib/src/models/` - Data models
- `lib/src/providers/` - Riverpod providers
- `lib/src/repositories/` - Data repositories
- `lib/src/services/` - Business logic
- `lib/src/screens/` - UI screens
- `lib/src/widgets/` - Reusable widgets

## Community

- Join discussions in GitHub Issues
- Share ideas and feedback
- Help other contributors

Thank you for contributing! 🙏
