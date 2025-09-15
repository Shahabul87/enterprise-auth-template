# Email Service Configuration Guide

## Overview
The enterprise authentication template supports multiple authentication methods including Magic Links, which require email service configuration. This guide explains how to set up SMTP email service for sending magic links and other email notifications.

## Email Service Options

The backend supports three email service providers:
1. **SMTP** (Gmail, Outlook, or any SMTP server)
2. **SendGrid** (Cloud email service)
3. **AWS SES** (Amazon Simple Email Service)

## SMTP Configuration (Recommended for Development)

### Using Gmail

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate an App Password**:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" as the app
   - Copy the generated 16-character password

3. **Configure Backend Environment Variables**:

Create or edit `backend/.env` file:

```env
# Email Configuration
EMAIL_ENABLED=true
EMAIL_FROM=your-email@gmail.com
EMAIL_FROM_NAME=Your App Name

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-16-char-app-password
SMTP_TLS=true
SMTP_SSL=false
```

### Using Other SMTP Providers

#### Outlook/Office365
```env
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_USER=your-email@outlook.com
SMTP_PASSWORD=your-password
SMTP_TLS=true
```

#### Custom SMTP Server
```env
SMTP_HOST=mail.your-domain.com
SMTP_PORT=587
SMTP_USER=noreply@your-domain.com
SMTP_PASSWORD=your-password
SMTP_TLS=true
```

## SendGrid Configuration (Production Recommended)

1. **Sign up** for SendGrid: https://sendgrid.com
2. **Create an API Key**:
   - Go to Settings → API Keys
   - Create a new API key with "Mail Send" permission
3. **Configure Backend**:

```env
# Disable SMTP
SMTP_HOST=

# Enable SendGrid
SENDGRID_API_KEY=your-sendgrid-api-key
EMAIL_FROM=noreply@your-domain.com
EMAIL_FROM_NAME=Your App Name
```

## AWS SES Configuration

1. **Set up AWS SES** in your AWS account
2. **Verify your domain or email addresses**
3. **Create IAM credentials** with SES send permissions
4. **Configure Backend**:

```env
# Disable SMTP
SMTP_HOST=

# Enable AWS SES
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
EMAIL_FROM=noreply@your-verified-domain.com
EMAIL_FROM_NAME=Your App Name
```

## Testing Email Configuration

### 1. Start the Backend Server
```bash
cd backend
source venv/bin/activate  # On Windows: venv\Scripts\activate
uvicorn app.main:app --reload
```

### 2. Test Magic Link via API
```bash
# Request a magic link
curl -X POST http://localhost:8000/api/v1/magic-links/request \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

### 3. Check Email Logs
The backend will log email sending attempts. Check the console output for:
- "Email sent successfully" - Email was sent
- "Failed to send email" - Configuration issue

## Magic Link Flow

1. **User requests magic link** on login page
2. **Backend generates secure token** (expires in 15 minutes)
3. **Email sent** with link: `http://localhost:3000/auth/verify-magic-link?token=xxx`
4. **User clicks link** in email
5. **Frontend verifies token** with backend
6. **User is logged in** and redirected to dashboard

## Email Templates

Email templates are located in `backend/app/templates/email/`:
- `magic_link.html` - Magic link email template
- `welcome.html` - Welcome email template
- `password_reset.html` - Password reset template

## Troubleshooting

### Common Issues

1. **"Failed to send email" error**
   - Check SMTP credentials are correct
   - Ensure 2FA is enabled and app password is used (Gmail)
   - Verify SMTP_HOST and SMTP_PORT are correct
   - Check firewall/network allows outbound SMTP

2. **"Connection refused" error**
   - Wrong SMTP_HOST or SMTP_PORT
   - Firewall blocking connection
   - Try telnet to test: `telnet smtp.gmail.com 587`

3. **"Authentication failed"**
   - Wrong username/password
   - For Gmail: Not using app password
   - Account security settings blocking access

4. **Emails going to spam**
   - Add SPF/DKIM records to your domain
   - Use a verified domain email address
   - Avoid spam trigger words in subject/content

### Testing Without Real Email

For development without email configuration:

1. **Set email to console mode** in backend:
```env
EMAIL_ENABLED=false
```

2. **Magic link tokens will appear in backend console**
3. **Manually construct the verification URL**:
```
http://localhost:3000/auth/verify-magic-link?token=<token-from-console>
```

## Security Considerations

1. **Never commit credentials** to version control
2. **Use environment variables** for all sensitive data
3. **Rotate credentials regularly**
4. **Use app-specific passwords** instead of account passwords
5. **Enable rate limiting** on magic link requests (already configured)
6. **Set appropriate token expiration** times

## Production Checklist

- [ ] Use production email service (SendGrid/SES)
- [ ] Configure SPF/DKIM/DMARC records
- [ ] Set production domain in email links
- [ ] Enable SSL/TLS for email transport
- [ ] Monitor email delivery rates
- [ ] Set up email bounce handling
- [ ] Configure email rate limits
- [ ] Test email templates across clients

## Support

For issues with email configuration:
1. Check backend logs for detailed error messages
2. Verify all environment variables are set correctly
3. Test SMTP connection independently
4. Review provider-specific documentation