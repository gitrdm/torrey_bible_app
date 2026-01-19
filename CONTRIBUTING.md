# Contributing to Torrey Bible Study App

Thank you for your interest in contributing to the Torrey Bible Study App! This document provides guidelines for contributing to this open-source Bible study application.

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please treat all community members with respect and kindness.

## Getting Started

### Prerequisites
- Flutter 3.27.1 or later
- Dart SDK (included with Flutter)
- VS Code or Android Studio (recommended IDEs)
- Git for version control

### Development Setup
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/torrey_bible_app.git
   cd torrey_bible_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## How to Contribute

### Reporting Issues
- Check existing issues before creating new ones
- Use clear, descriptive titles
- Include steps to reproduce bugs
- Specify platform and Flutter version
- Add screenshots for UI issues

### Feature Requests
- Describe the feature's purpose and benefit
- Consider impact on app performance and size
- Discuss implementation approach if possible
- Check if feature aligns with app's core purpose

### Code Contributions

#### Pull Request Process
1. Create a feature branch from `main`
2. Make your changes following our coding standards
3. Test your changes thoroughly
4. Update documentation if needed
5. Submit a pull request with clear description

#### Coding Standards

##### Flutter/Dart Guidelines
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Keep functions small and focused
- Add documentation for public APIs
- Use `const` constructors where possible

##### Code Organization
```
lib/
├── models/          # Data models and structures
├── services/        # Business logic and data operations
├── providers/       # State management
├── screens/         # UI screens and pages
├── widgets/         # Reusable UI components
├── router/          # Navigation configuration
└── utils/          # Utility functions
```

##### State Management
- Use Provider pattern consistently
- Keep state classes focused and minimal
- Implement proper disposal for resources
- Use ChangeNotifier for UI updates

##### UI Guidelines
- Follow Material Design 3 principles
- Ensure responsive design for all screen sizes
- Implement proper loading and error states
- Add accessibility features (semantic labels, etc.)

#### Testing Requirements
- Write unit tests for business logic
- Add widget tests for UI components
- Include integration tests for critical flows
- Maintain minimum 80% test coverage

#### Documentation
- Update README.md for feature changes
- Add inline code documentation
- Update CHANGELOG.md for user-facing changes
- Include usage examples for new APIs

### Data Contributions

#### Bible Translations
- Ensure proper copyright permissions
- Use standard JSON format matching existing structure
- Include complete book/chapter/verse hierarchy
- Validate data integrity before submission

#### Topical Content
- Maintain theological accuracy
- Follow existing categorization structure
- Include proper verse references
- Verify cross-reference accuracy

## Development Guidelines

### Architecture Principles
- Separation of concerns between UI and business logic
- Single responsibility for classes and functions
- Dependency injection where appropriate
- Clean, readable code over clever solutions

### Performance Considerations
- Optimize for app startup time
- Minimize memory usage with large datasets
- Use lazy loading where beneficial
- Profile performance on lower-end devices

### Platform Support
- Test on multiple platforms (Android, iOS, Web, Desktop)
- Handle platform-specific behaviors appropriately
- Ensure consistent UX across platforms
- Optimize for different screen sizes and orientations

## Review Process

### Code Review Checklist
- [ ] Code follows established patterns and style
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] Performance impact is considered
- [ ] Accessibility features are maintained
- [ ] Cross-platform compatibility is verified

### Review Criteria
- **Functionality**: Code works as intended
- **Quality**: Clean, maintainable code
- **Testing**: Adequate test coverage
- **Documentation**: Clear and complete
- **Performance**: No significant regressions
- **Compatibility**: Works across target platforms

## Community Guidelines

### Communication
- Be respectful and professional
- Ask questions when unclear
- Provide constructive feedback
- Help newcomers get started

### Issue Management
- Use appropriate labels for issues and PRs
- Keep discussions focused and on-topic
- Close resolved issues promptly
- Reference related issues when applicable

## Getting Help

### Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design Guidelines](https://m3.material.io/)
- [Provider Pattern Documentation](https://pub.dev/packages/provider)

### Support Channels
- GitHub Issues for bug reports and feature requests
- Discussions tab for questions and general topics
- Code review comments for specific implementation questions

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes for significant contributions
- GitHub contributor graphs and statistics

Thank you for helping make the Torrey Bible Study App better for everyone!