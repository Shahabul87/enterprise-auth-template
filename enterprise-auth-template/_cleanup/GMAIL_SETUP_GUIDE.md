# Gmail SMTP Setup Guide for shahabul7115@gmail.com

## ✅ Configuration Status
Your .env file has been configured with:
- Email: shahabul7115@gmail.com
- SMTP Host: smtp.gmail.com
- Port: 587 (TLS)

## 🔐 Next Step: Generate App Password

1. **Go to Google Account Security**:
   - Direct link: https://myaccount.google.com/apppasswords
   - Or: Google Account → Security → 2-Step Verification → App passwords

2. **Generate App Password**:
   - Select app: **Mail**
   - Select device: **Other** → Type: "Enterprise Auth App"
   - Click **Generate**
   - You'll get a 16-character password like: `abcd efgh ijkl mnop`

3. **Update Your .env File**:
   ```bash
   cd backend
   # Edit the .env file and replace YOUR_APP_PASSWORD_HERE with your app password
   # Remove spaces from the password: abcdefghijklmnop
   ```

   Line to update in .env:
   ```
   SMTP_PASSWORD=abcdefghijklmnop  # Your 16-char password without spaces
   ```

## 📧 Test Email Addresses
You can use Gmail aliases for testing multiple accounts:
- shahabul7115+test1@gmail.com
- shahabul7115+test2@gmail.com
- shahabul7115+admin@gmail.com
- shahabul7115+user@gmail.com

All these will arrive in your main inbox but appear as different users in the system.

## 🧪 Quick Test Commands

After updating your App Password, test email sending:

```bash
# Start the backend server
cd backend
uvicorn app.main:app --reload

# In another terminal, test registration with email verification
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "shahabul7115+test1@gmail.com",
    "password": "TestPass123!",
    "full_name": "Test User"
  }'
```

## 🔍 Troubleshooting

If emails don't send, check:

1. **App Password**: Make sure you removed all spaces
2. **2FA Enabled**: Required for App Passwords to work
3. **Backend Logs**: Check for SMTP errors
   ```bash
   # Watch backend logs
   cd backend
   uvicorn app.main:app --reload --log-level debug
   ```

4. **Test SMTP Connection**:
   ```python
   # Run this Python script to test SMTP
   python test_smtp.py
   ```

## 📝 Important Notes

- **Never commit** your App Password to Git
- The .env file is already in .gitignore
- Gmail limit: 500 emails/day (free account)
- For production, consider SendGrid or AWS SES

## ✨ Ready to Test!

Once you've added your App Password to the .env file, you can test:
1. **Registration** with email verification
2. **Password reset** via email
3. **Forgot password** flow

Your backend is configured and ready - just add the App Password!