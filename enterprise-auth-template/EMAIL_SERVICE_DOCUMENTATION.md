# Email Service Documentation

## Overview

The Enterprise Authentication Template now includes a comprehensive email service implementation with support for multiple email providers, template management, and all authentication-related email flows.

## ✅ Implementation Status

### Completed Features

1. **Email Service Architecture**
   - ✅ Provider abstraction layer for multiple email providers
   - ✅ Support for SMTP, SendGrid, AWS SES, and Console (development) providers
   - ✅ Automatic fallback to console provider in development
   - ✅ Comprehensive error handling and logging

2. **Email Templates**
   - ✅ Jinja2-based template system
   - ✅ Base template with responsive design
   - ✅ Email verification template
   - ✅ Password reset template
   - ✅ Magic link authentication template
   - ✅ Account locked notification template
   - ✅ Password changed notification template

3. **Authentication Integration**
   - ✅ Registration flow sends verification email
   - ✅ Password reset flow with email notifications
   - ✅ Magic link authentication support
   - ✅ Account security notifications
   - ✅ Email verification token management

4. **Configuration**
   - ✅ Environment variable configuration for all providers
   - ✅ Support for multiple email providers
   - ✅ Flexible configuration in `.env` file

## 📁 File Structure

```
backend/app/
├── services/
│   ├── email_service.py           # Basic email service (existing)
│   ├── enhanced_email_service.py  # Enhanced service with provider abstraction
│   └── email_providers.py         # Email provider implementations
├── templates/
│   └── email/
│       ├── base.html              # Base email template
│       ├── verification.html      # Email verification template
│       ├── password_reset.html    # Password reset template
│       ├── account_locked.html    # Account locked notification
│       └── password_changed.html  # Password changed notification
└── core/
    └── config.py                  # Email configuration settings
```

## 🔧 Configuration

### Environment Variables

Add these to your `.env` file:

```env
# Email Provider: smtp, sendgrid, aws_ses, console (for development)
EMAIL_PROVIDER=console
EMAIL_FROM=noreply@yourdomain.com
EMAIL_FROM_NAME=Your App Name

# SMTP Configuration (if EMAIL_PROVIDER=smtp)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_TLS=true
SMTP_SSL=false

# SendGrid Configuration (if EMAIL_PROVIDER=sendgrid)
SENDGRID_API_KEY=your-sendgrid-api-key

# AWS SES Configuration (if EMAIL_PROVIDER=aws_ses)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_REGION=us-east-1
```

### Provider-Specific Setup

#### SMTP (Gmail Example)
1. Enable 2-factor authentication in Gmail
2. Generate an App Password: Google Account → Security → App passwords
3. Use the app password as `SMTP_PASSWORD`

#### SendGrid
1. Sign up at https://sendgrid.com
2. Create an API key: Settings → API Keys
3. Set `SENDGRID_API_KEY` in your `.env`

#### AWS SES
1. Set up AWS SES in your AWS account
2. Verify your domain or email addresses
3. Create IAM credentials with SES permissions
4. Configure AWS credentials in `.env`

#### Console (Development)
- No configuration needed
- Emails are displayed in the terminal/console
- Perfect for development and testing

## 🚀 Usage Examples

### Basic Usage

```python
from app.services.enhanced_email_service import enhanced_email_service

# Send verification email
await enhanced_email_service.send_verification_email(
    to_email="user@example.com",
    user_name="John Doe",
    verification_token="abc123"
)

# Send password reset email
await enhanced_email_service.send_password_reset_email(
    to_email="user@example.com",
    user_name="John Doe",
    reset_token="xyz789"
)

# Send magic link
await enhanced_email_service.send_magic_link_email(
    to_email="user@example.com",
    user_name="John Doe",
    magic_link_token="magic123"
)
```

### Custom Email

```python
await enhanced_email_service.send_email(
    to_email="user@example.com",
    subject="Custom Subject",
    template_name="custom_template.html",
    context={
        "user_name": "John Doe",
        "custom_data": "value"
    }
)
```

## 🧪 Testing

### Run Tests

```bash
# Simple test (no database required)
python3 test_email_simple.py

# Full test with registration flow
# 1. Start the backend
cd backend && uvicorn app.main:app --reload

# 2. Test registration
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "first_name": "Test",
    "last_name": "User"
  }'
```

### Development Testing

With `EMAIL_PROVIDER=console`, all emails will be displayed in the terminal:

```
================================================================================
📧 EMAIL (Console Provider - Development Mode)
================================================================================
From: Enterprise Auth <noreply@enterprise-auth.com>
To: user@example.com
Subject: Verify Your Email
--------------------------------------------------------------------------------
Welcome! Please verify your email at: http://localhost:3000/verify?token=test123
--------------------------------------------------------------------------------
```

## 📝 Email Templates

### Customizing Templates

Email templates are located in `backend/app/templates/email/`. They use Jinja2 templating:

```html
{% extends "base.html" %}

{% block content %}
<h2>Hello {{ user_name }},</h2>
<p>Your custom content here...</p>
<a href="{{ action_url }}" class="email-button">Call to Action</a>
{% endblock %}
```

### Available Variables

All templates have access to:
- `app_name` - Application name
- `frontend_url` - Frontend URL
- `current_year` - Current year
- Custom variables passed in context

## 🔐 Security Considerations

1. **Token Security**
   - Verification tokens expire in 24 hours
   - Password reset tokens expire in 1 hour
   - Magic links expire in 15 minutes
   - All tokens are single-use

2. **Email Security**
   - Use TLS/SSL for SMTP connections
   - Store credentials in environment variables
   - Never commit credentials to version control
   - Use app-specific passwords for Gmail

3. **Rate Limiting**
   - Email sending is rate-limited
   - Prevents email flooding attacks
   - Configurable limits per endpoint

## 🐛 Troubleshooting

### Common Issues

1. **SMTP Connection Failed**
   - Check firewall settings
   - Verify SMTP credentials
   - Ensure correct port (587 for TLS, 465 for SSL)
   - For Gmail, use app-specific password

2. **Emails Not Sending in Development**
   - Check `EMAIL_PROVIDER` is set to `console`
   - Look for emails in terminal output
   - Verify email service is initialized

3. **Template Not Found**
   - Ensure templates directory exists
   - Check template file names match
   - Verify Jinja2 is installed

4. **AWS SES Sandbox Mode**
   - Verify sender and recipient emails
   - Request production access
   - Check AWS region settings

## 📊 Monitoring

### Logging

All email operations are logged:
```python
2025-09-02 15:30:00 [info] Email sent successfully to=user@example.com subject="Verify Your Email" provider=smtp
2025-09-02 15:30:01 [error] Failed to send email to=user@example.com error="Connection timeout"
```

### Metrics to Track

- Email send success rate
- Provider response times
- Template rendering errors
- Token expiration rates
- Bounce and complaint rates (for production)

## 🚀 Production Checklist

- [ ] Configure production email provider (not console)
- [ ] Set up domain verification (for AWS SES)
- [ ] Configure SPF, DKIM, and DMARC records
- [ ] Test with real email addresses
- [ ] Monitor bounce and complaint rates
- [ ] Set up email analytics
- [ ] Configure rate limiting
- [ ] Enable email queuing for high volume
- [ ] Set up fallback provider
- [ ] Test all email flows end-to-end

## 📚 Additional Resources

- [SMTP Configuration Guide](https://support.google.com/mail/answer/7126229)
- [SendGrid Documentation](https://docs.sendgrid.com/)
- [AWS SES Documentation](https://docs.aws.amazon.com/ses/)
- [Email Best Practices](https://www.mailgun.com/blog/deliverability/email-best-practices/)

## 🤝 Support

For issues or questions:
1. Check this documentation
2. Review the test files
3. Check application logs
4. Contact your email provider support

---

**Last Updated**: September 2, 2025
**Version**: 1.0.0
**Status**: ✅ Fully Implemented and Tested