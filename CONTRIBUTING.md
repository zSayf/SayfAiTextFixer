# Contributing to Sayf AI Text Fixer

🎉 **Thank you for your interest in contributing to Sayf AI Text Fixer!** 

We welcome contributions from the community and are grateful for your help in making this tool better for everyone.

## 🚀 **Getting Started**

### Prerequisites
- **AutoHotkey v2.0+** installed on Windows 10/11
- **Google Gemini API Key** for testing
- **Git** for version control
- Basic understanding of AutoHotkey scripting

### Development Setup
1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/SayfAiTextFixer.git
   cd SayfAiTextFixer
   ```
3. **Test the current version** to understand the functionality
4. **Set up your API key** for testing

## 📋 **How to Contribute**

### 🐛 **Reporting Bugs**
- **Search existing issues** first to avoid duplicates
- **Use the bug report template** when creating new issues
- **Include specific details:**
  - Windows version
  - AutoHotkey version
  - Steps to reproduce
  - Expected vs actual behavior
  - Error messages or logs

### ✨ **Suggesting Features**
- **Check existing feature requests** first
- **Use the feature request template**
- **Describe the problem** your feature would solve
- **Explain your proposed solution** with examples
- **Consider implementation complexity**

### 💻 **Code Contributions**

#### **Coding Standards**
Follow the project's coding guidelines in `AHK_V2_CODING_RULES.md`:

- **Error Handling**: All functions must use try-catch-finally patterns
- **Parameter Validation**: Validate all function inputs
- **Resource Management**: Proper cleanup of COM objects and resources
- **Bilingual Support**: Maintain English/Arabic compatibility
- **Documentation**: Comprehensive inline comments

#### **Development Process**
1. **Create a feature branch**: `git checkout -b feature/your-feature-name`
2. **Follow coding standards** documented in the repository
3. **Test thoroughly** on different Windows versions
4. **Update documentation** if needed
5. **Commit with clear messages**: Use conventional commit format

#### **Example Commit Messages**
```
feat: add new summarization mode for long texts
fix: resolve multi-monitor GUI positioning issue  
docs: update README with v4.5.0 features
refactor: improve error handling in API manager
```

### 🧪 **Testing Guidelines**

#### **Manual Testing Checklist**
- [ ] Test all 19 AI processing modes
- [ ] Verify bilingual text handling (Arabic/English)
- [ ] Test auto-startup functionality
- [ ] Check multi-monitor GUI positioning
- [ ] Validate settings persistence
- [ ] Test API key validation and caching
- [ ] Test Humanizer mode specifically for natural language conversion

#### **Test Scenarios**
- **Different text types**: Emails, documents, code comments
- **Mixed languages**: Arabic-English content
- **Edge cases**: Very long text, special characters, empty selections
- **System integration**: Different Windows versions, multiple monitors

## 🔧 **Technical Requirements**

### **Code Quality Standards**
- **Zero compilation errors** - Use AutoHotkey v2 syntax checking
- **Comprehensive error handling** - All functions must handle failures gracefully
- **Memory management** - Proper resource cleanup and disposal
- **Performance optimization** - Efficient algorithms and minimal resource usage

### **Documentation Requirements**
- **Inline comments** for complex logic
- **Function documentation** with parameters and return values
- **Update README** for new features
- **Changelog entries** for all user-facing changes

## 🌍 **Internationalization**

When adding new features:
- **Support both English and Arabic** interfaces
- **Use resource strings** instead of hardcoded text
- **Test with RTL (Right-to-Left)** text direction
- **Maintain cultural sensitivity** in user messages

## 📝 **Pull Request Process**

### **Before Submitting**
1. **Ensure your code follows** project standards
2. **Test thoroughly** on your local system
3. **Update documentation** as needed
4. **Write clear commit messages**
5. **Rebase on latest main branch**

### **PR Template**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature  
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Manual testing completed
- [ ] All existing functionality verified
- [ ] New feature tested thoroughly

## Checklist
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] Commits are clean and descriptive
```

### **Review Process**
- **Maintainer review** required for all PRs
- **Feedback incorporation** may be requested
- **Final testing** by maintainers before merge
- **Merge to main** after approval

## 🏷️ **Issue Labels**

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `priority-high` - Critical issues
- `priority-low` - Nice-to-have improvements

## 💬 **Community Guidelines**

### **Communication**
- **Be respectful** and professional
- **Use English or Arabic** in discussions
- **Stay on topic** in issue discussions
- **Provide constructive feedback**

### **Code of Conduct**
Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md). We are committed to providing a welcoming and inclusive environment for all contributors.

## 🙏 **Recognition**

Contributors are recognized in:
- **README.md** contributors section
- **Release notes** for significant contributions
- **GitHub contributors** page

## 📞 **Getting Help**

- **GitHub Issues** - For bugs and feature requests
- **GitHub Discussions** - For questions and community chat
- **Documentation** - Check existing docs first

## 🚀 **Ready to Contribute?**

1. **Star the repository** ⭐
2. **Fork and clone** your copy
3. **Pick an issue** or propose a new feature
4. **Start coding** following our guidelines
5. **Submit your PR** and await review

**Thank you for helping make Sayf AI Text Fixer better for everyone! 🎉**
