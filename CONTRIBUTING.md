# Contributing to iSee

**Version:** Beta V1.0.0  
**Last Updated:** October 25, 2025

Thank you for your interest in contributing to iSee! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Issues

1. **Check existing issues** before creating a new one
2. **Use the issue template** and provide:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (macOS version, device model)
   - Screenshots if applicable

### Suggesting Features

1. **Check existing feature requests** first
2. **Describe the feature** clearly
3. **Explain the use case** and why it would be valuable
4. **Consider privacy implications** - iSee prioritizes user privacy

### Submitting Code

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** following our coding standards
4. **Test thoroughly** on macOS
5. **Commit with clear messages**: `git commit -m "Add amazing feature"`
6. **Push to your fork**: `git push origin feature/amazing-feature`
7. **Create a Pull Request**

## Development Setup

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0 or later
- Git

### Setup Steps
1. Fork and clone the repository
2. Open `isee.xcodeproj` in Xcode
3. Build and run the project
4. Test on your MacBook

## Coding Standards

### Swift Style Guide
- Follow Apple's Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small
- All new Swift files must include header comment with file name, project name, and date
- Refer to `COMPLETE_LOGIC_DOCUMENTATION.md` for architecture patterns

### Privacy Guidelines
- **No data collection**: Never add analytics or telemetry
- **On-device processing**: Keep all processing local
- **Minimal permissions**: Only request necessary permissions
- **Transparent code**: Make privacy practices clear in code

### Code Organization
- Keep related functionality together
- Use proper separation of concerns
- Follow MVVM pattern for UI components
- Add unit tests for business logic

## Testing

### Manual Testing
- Test on different macOS versions
- Test with different camera configurations
- Test privacy permissions flow
- Test performance with multiple faces

### Automated Testing
- Add unit tests for new features
- Test edge cases and error conditions
- Ensure no memory leaks

## Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new functionality
3. **Update version** if applicable
4. **Ensure all tests pass**
5. **Request review** from maintainers

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on macOS
- [ ] Added unit tests
- [ ] Manual testing completed

## Privacy Impact
- [ ] No privacy impact
- [ ] Privacy impact documented
- [ ] Privacy review required
```

## Release Process

Releases are managed by project maintainers. Version numbering follows semantic versioning (MAJOR.MINOR.PATCH).

## Questions?

- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Security**: Report security issues privately to maintainers

Thank you for contributing to iSee! 🎉
