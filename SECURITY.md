# Security Policy

## 🛡️ **Supported Versions**

We actively support the following versions of Sayf AI Text Fixer with security updates:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 2.9.x   | ✅ Current Release | Fully Supported |
| 2.0.x   | ✅ Previous Major  | Security Fixes Only |
| 1.5.x   | ❌ Legacy          | No Longer Supported |
| < 1.5   | ❌ Deprecated      | No Longer Supported |

## 🔒 **Security Considerations**

### **API Key Security**
- **Local Storage**: API keys are stored locally in encrypted configuration files
- **No Transmission**: Keys are only sent directly to Google Gemini API via HTTPS
- **No Logging**: API keys are never logged or cached in plain text
- **User Responsibility**: Keep your API keys secure and regenerate if compromised

### **Data Privacy**
- **Local Processing**: All text processing occurs locally except AI API calls
- **No Data Retention**: No user text is stored or retained by the application
- **Temporary Processing**: Text is only held in memory during active processing
- **No Analytics**: No usage analytics or telemetry data is collected

### **Network Security**
- **HTTPS Only**: All API communications use encrypted HTTPS connections
- **Certificate Validation**: SSL/TLS certificates are properly validated
- **No Proxy Issues**: Direct API connections prevent man-in-the-middle attacks
- **Firewall Friendly**: Standard HTTPS port 443 communication

## 🚨 **Reporting Security Vulnerabilities**

We take security seriously. If you discover a security vulnerability, please follow these steps:

### **DO NOT** Report Publicly
- **Do not** create public GitHub issues for security vulnerabilities
- **Do not** discuss vulnerabilities in public forums or social media
- **Do not** share vulnerability details until we've had time to address them

### **Preferred Reporting Method**
1. **Email**: Send details to the repository owner via GitHub profile
2. **GitHub Security**: Use GitHub's private security reporting feature
3. **Direct Message**: Contact @zSayf through GitHub

### **Include in Your Report**
- **Description**: Clear description of the vulnerability
- **Impact**: Potential impact and attack scenarios
- **Reproduction**: Step-by-step reproduction instructions
- **Environment**: Windows version, AutoHotkey version, application version
- **Proof of Concept**: Code or screenshots demonstrating the issue (if applicable)

### **Response Timeline**
- **Initial Response**: Within 48 hours of report
- **Assessment**: Vulnerability assessment within 7 days
- **Fix Development**: Based on severity (see below)
- **Disclosure**: Coordinated disclosure after fix is available

## ⚡ **Severity Levels**

### **Critical (24-48 hour response)**
- Remote code execution
- API key exposure or theft
- System privilege escalation
- Data exfiltration capabilities

### **High (1 week response)**
- Local privilege escalation
- Significant data exposure
- Authentication bypass
- Denial of service attacks

### **Medium (2 weeks response)**
- Information disclosure
- Configuration vulnerabilities
- Minor privilege escalation
- Input validation issues

### **Low (30 days response)**
- UI spoofing
- Minor information leaks
- Non-security bugs with security implications

## 🔐 **Security Best Practices for Users**

### **API Key Management**
- **Use dedicated keys**: Create separate API keys for different applications
- **Monitor usage**: Regularly check API usage in Google Console
- **Rotate keys**: Periodically regenerate API keys as best practice
- **Limit permissions**: Use minimum required API permissions

### **Installation Security**
- **Download from official sources**: Only use GitHub releases or verified sources
- **Verify file integrity**: Check file sizes and signatures when possible
- **Keep updated**: Always use the latest supported version
- **Scan for malware**: Use antivirus software to scan downloaded files

### **Runtime Security**
- **Run with minimal privileges**: Don't run as administrator unless required
- **Monitor API usage**: Watch for unusual API consumption patterns
- **Review logs**: Periodically check application logs for anomalies
- **Network monitoring**: Monitor network connections if concerned

## 🛠️ **Security Features**

### **Built-in Protections**
- **Input Validation**: All user inputs are validated and sanitized
- **Error Handling**: Comprehensive error handling prevents information leaks
- **Resource Limits**: Memory and processing limits prevent resource exhaustion
- **Injection Protection**: AI prompts are sanitized to prevent injection attacks

### **Configuration Security**
- **Encrypted Storage**: Sensitive configuration data is encrypted
- **File Permissions**: Configuration files have restricted access permissions
- **Validation**: All configuration values are validated before use
- **Recovery**: Self-healing configuration system prevents corruption exploitation

## 📋 **Security Audit Information**

### **Last Security Review**
- **Date**: August 2025
- **Version**: v2.9.1
- **Scope**: Full application security assessment
- **Findings**: No critical vulnerabilities identified

### **Known Security Considerations**
- **AutoHotkey Runtime**: Inherits security characteristics of AutoHotkey v2
- **Windows Integration**: Uses Windows APIs for system integration features
- **Registry Access**: Requires registry access for auto-startup functionality
- **Network Access**: Requires internet access for AI API functionality

## 🔄 **Security Update Policy**

### **Automatic Updates**
- Currently, manual updates are required
- Security notifications via GitHub releases
- Critical security updates will be clearly marked

### **Update Verification**
- All releases are signed and verified
- SHA checksums provided for file integrity
- GitHub release artifacts are the official distribution method

## 🙏 **Acknowledgments**

We appreciate security researchers and users who help keep Sayf AI Text Fixer secure:

- **Responsible Disclosure**: Thanks to all who follow responsible disclosure practices
- **Community Support**: Gratitude to users who report security concerns promptly
- **Security Researchers**: Recognition for professional security assessments

## 📞 **Additional Resources**

- **AutoHotkey Security**: https://www.autohotkey.com/docs/v2/misc/Security.htm
- **Google API Security**: https://cloud.google.com/security
- **Windows Security**: https://docs.microsoft.com/en-us/windows/security/

---

**For non-security related issues, please use our [GitHub Issues](https://github.com/zSayf/SayfAiTextFixer/issues) page.**