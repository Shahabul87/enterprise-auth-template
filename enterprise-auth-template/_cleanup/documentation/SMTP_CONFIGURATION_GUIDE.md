# 📧 SMTP Configuration Guide

Complete guide to configure email services for the Enterprise Authentication Template.

## 📋 Overview

The template includes a comprehensive email service that supports:
- **Welcome emails** for new users
- **Password reset emails** with secure tokens  
- **Magic link emails** for passwordless authentication
- **2FA verification codes** via email
- **Account notifications** (security alerts, changes)
- **Account locked notifications**
- **Password changed confirmations**

## 🔧 Environment Configuration

### Required Environment Variables

Add these variables to your `.env` file:

```bash
# Email Service Configuration
SMTP_HOST=smtp.gmail.com              # SMTP server hostname
SMTP_PORT=587                         # SMTP port (587 for TLS, 465 for SSL)
SMTP_USER=your-email@gmail.com        # SMTP username (email address)
SMTP_PASSWORD=your-app-password       # SMTP password or app password
SMTP_TLS=true                         # Enable TLS (recommended)
SMTP_SSL=false                        # Enable SSL (use instead of TLS)
EMAIL_FROM=noreply@yourdomain.com     # From email address

# Frontend URL (for email links)
FRONTEND_URL=http://localhost:3000    # Your frontend URL
```

## 🌐 Popular Email Providers

### 1. Gmail (Google Workspace)

**Configuration:**
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password        # Use App Password, not account password
SMTP_TLS=true
SMTP_SSL=false
```

**Setup Steps:**
1. Enable 2-Factor Authentication on your Google account
2. Go to [Google App Passwords](https://myaccount.google.com/apppasswords)
3. Generate an app password for "Mail"
4. Use the 16-character app password as `SMTP_PASSWORD`

### 2. Outlook/Hotmail (Microsoft)

**Configuration:**
```bash
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_USER=your-email@outlook.com
SMTP_PASSWORD=your-password
SMTP_TLS=true
SMTP_SSL=false
```

### 3. SendGrid (Recommended for Production)

**Configuration:**
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey                      # Always "apikey" for SendGrid
SMTP_PASSWORD=your-sendgrid-api-key
SMTP_TLS=true
SMTP_SSL=false
```

**Setup Steps:**
1. Sign up at [SendGrid](https://sendgrid.com/)
2. Create an API key with "Mail Send" permissions
3. Verify your sender domain or email
4. Use the API key as `SMTP_PASSWORD`

### 4. Mailgun (Alternative Production Option)

**Configuration:**
```bash
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USER=postmaster@mg.yourdomain.com
SMTP_PASSWORD=your-mailgun-smtp-password
SMTP_TLS=true
SMTP_SSL=false
```

### 5. AWS SES (Amazon Simple Email Service)

**Configuration:**
```bash
SMTP_HOST=email-smtp.us-east-1.amazonaws.com  # Replace with your region
SMTP_PORT=587
SMTP_USER=your-ses-smtp-username
SMTP_PASSWORD=your-ses-smtp-password
SMTP_TLS=true
SMTP_SSL=false
```

### 6. Postmark

**Configuration:**
```bash
SMTP_HOST=smtp.postmarkapp.com
SMTP_PORT=587
SMTP_USER=your-postmark-server-token
SMTP_PASSWORD=your-postmark-server-token
SMTP_TLS=true
SMTP_SSL=false
```

## 🚀 Production Recommendations

### Best Practices

1. **Use Dedicated Email Services**
   - SendGrid, Mailgun, SES, or Postmark for production
   - Better deliverability than Gmail/Outlook
   - Professional email analytics and management

2. **Domain Authentication**
   - Set up SPF, DKIM, and DMARC records
   - Use a dedicated subdomain (e.g., mail.yourdomain.com)
   - Verify sender domains with your provider

3. **Security**
   - Use environment variables for credentials
   - Enable TLS/SSL encryption
   - Rotate credentials regularly
   - Use API keys instead of passwords when possible

4. **Monitoring**
   - Set up email delivery monitoring
   - Track bounce rates and spam complaints
   - Monitor email quotas and limits

### Example Production Configuration

```bash
# Production Email Configuration
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=SG.your-actual-sendgrid-api-key-here
SMTP_TLS=true
SMTP_SSL=false
EMAIL_FROM=noreply@yourdomain.com
FRONTEND_URL=https://yourdomain.com
```

## 📨 Email Templates

The service includes beautiful, responsive HTML email templates:

### Available Templates

1. **Welcome Email** (`welcome.html`)
   - Modern gradient design
   - Feature highlights
   - Call-to-action buttons
   - Mobile responsive

2. **2FA Verification** (`2fa_verification.html`)
   - Large, clear verification code
   - Security warnings
   - Expiration timer
   - Help links

3. **Account Notifications** (`account_notification.html`)
   - Dynamic content based on notification type
   - Color-coded by severity (success, warning, danger, info)
   - Action buttons and security tips

4. **Built-in Templates**
   - Password reset emails
   - Magic link emails
   - Account locked notifications
   - Password changed confirmations

### Template Customization

Templates are located in `backend/app/templates/email/` and use Jinja2 templating:

```html
<!-- Example customization -->
<h1>Welcome to {{ app_name }}!</h1>
<p>Hello, {{ user_name }}!</p>
<a href="{{ dashboard_url }}" class="button">Get Started</a>
```

## 🧪 Testing Email Configuration

### 1. Basic Test

```python
# Test basic email functionality
from app.services.email_service import email_service

# Test email sending
result = await email_service.send_welcome_email(
    to_email="test@example.com",
    user_name="Test User"
)
print(f"Email sent: {result}")
```

### 2. Using the Test Script

Run the included test script:

```bash
cd backend
python test_email_service.py
```

### 3. Environment Variables Test

```bash
# Check if email service is configured
python -c "
from app.core.config import get_settings
settings = get_settings()
print(f'SMTP Host: {settings.SMTP_HOST}')
print(f'SMTP User: {settings.SMTP_USER}')
print(f'Configured: {bool(settings.SMTP_HOST and settings.SMTP_USER)}')
"
```

## 🔍 Troubleshooting

### Common Issues

1. **Authentication Failed**
   ```
   Error: Failed to connect to email server: (535, '5.7.8 Username and Password not accepted')
   ```
   - **Solution:** Use app passwords for Gmail, verify credentials

2. **Connection Timeout**
   ```
   Error: Failed to connect to email server: timed out
   ```
   - **Solution:** Check SMTP host/port, firewall settings

3. **TLS/SSL Issues**
   ```
   Error: SSL: CERTIFICATE_VERIFY_FAILED
   ```
   - **Solution:** Verify TLS/SSL settings, check port (587 for TLS, 465 for SSL)

4. **Emails Going to Spam**
   - **Solution:** Set up SPF/DKIM/DMARC, use dedicated email service

### Debug Mode

Enable email debug logging:

```python
import logging
logging.getLogger("mail").setLevel(logging.DEBUG)
```

### Health Check

The service includes a configuration check:

```python
from app.services.email_service import email_service
print(f"Email service configured: {email_service.is_configured}")
```

## 📊 Monitoring and Analytics

### Recommended Metrics

1. **Delivery Rates**
   - Track successful deliveries
   - Monitor bounce rates
   - Watch spam complaints

2. **Email Engagement**
   - Open rates (if tracking enabled)
   - Click-through rates
   - Unsubscribe rates

3. **System Health**
   - Email queue length
   - Sending errors
   - API rate limits

### Example Monitoring Setup

```python
# Add to your monitoring dashboard
async def email_health_check():
    """Check email service health"""
    try:
        # Test email configuration
        if not email_service.is_configured:
            return {"status": "error", "message": "Email not configured"}
        
        # Test SMTP connection
        with email_service._get_smtp_connection() as smtp:
            status = smtp.noop()
            
        return {"status": "healthy", "smtp_status": status}
    except Exception as e:
        return {"status": "error", "message": str(e)}
```

## 🔐 Security Best Practices

1. **Credential Management**
   - Never commit email credentials to version control
   - Use environment variables or secret management systems
   - Rotate credentials regularly

2. **Email Security**
   - Enable TLS/SSL encryption
   - Validate recipient email addresses
   - Implement rate limiting for email sending

3. **Content Security**
   - Sanitize user-generated content in emails
   - Avoid embedding sensitive information
   - Use secure tokens for password resets

4. **Compliance**
   - Include unsubscribe links where required
   - Respect email preferences
   - Follow GDPR/CAN-SPAM regulations

## 📚 Additional Resources

- [SendGrid Documentation](https://docs.sendgrid.com/)
- [Mailgun Documentation](https://documentation.mailgun.com/)
- [AWS SES Documentation](https://docs.aws.amazon.com/ses/)
- [Email Deliverability Guide](https://sendgrid.com/blog/email-deliverability-guide/)
- [SPF/DKIM/DMARC Setup](https://support.google.com/a/answer/33786)

---

**🎉 Email service is now ready!** Configure your SMTP settings and start sending beautiful, professional emails to your users.