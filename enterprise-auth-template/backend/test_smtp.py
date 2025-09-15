#!/usr/bin/env python3
"""
Simple SMTP connection test for Gmail
Run this after adding your App Password to verify email configuration
"""

import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_smtp_connection():
    """Test SMTP connection and send a test email"""

    # Get configuration from environment
    smtp_host = os.getenv('SMTP_HOST', 'smtp.gmail.com')
    smtp_port = int(os.getenv('SMTP_PORT', '587'))
    smtp_user = os.getenv('SMTP_USER', 'shahabul7115@gmail.com')
    smtp_password = os.getenv('SMTP_PASSWORD', '')
    email_from = os.getenv('EMAIL_FROM', 'shahabul7115@gmail.com')

    if not smtp_password or smtp_password == 'YOUR_APP_PASSWORD_HERE':
        print("❌ Error: Please add your Gmail App Password to the .env file")
        print("   Update SMTP_PASSWORD in backend/.env")
        return False

    print(f"📧 Testing SMTP connection to {smtp_host}:{smtp_port}")
    print(f"   Using email: {smtp_user}")

    try:
        # Create SMTP connection
        print("🔌 Connecting to SMTP server...")
        server = smtplib.SMTP(smtp_host, smtp_port)
        server.starttls()

        print("🔐 Authenticating...")
        server.login(smtp_user, smtp_password)

        print("✅ SMTP connection successful!")

        # Send a test email
        print("\n📨 Sending test email...")

        msg = MIMEMultipart('alternative')
        msg['Subject'] = 'Enterprise Auth - SMTP Test Successful'
        msg['From'] = email_from
        msg['To'] = smtp_user  # Send to yourself

        # Create the email body
        text = """
        SMTP Configuration Test Successful!

        Your Gmail SMTP is properly configured for the Enterprise Auth application.

        You can now test:
        - User registration with email verification
        - Password reset emails
        - Forgot password flow

        Configuration:
        - SMTP Host: {}
        - SMTP Port: {}
        - Email From: {}
        """.format(smtp_host, smtp_port, email_from)

        html = """
        <html>
          <body>
            <h2>✅ SMTP Configuration Test Successful!</h2>
            <p>Your Gmail SMTP is properly configured for the Enterprise Auth application.</p>

            <h3>You can now test:</h3>
            <ul>
              <li>User registration with email verification</li>
              <li>Password reset emails</li>
              <li>Forgot password flow</li>
            </ul>

            <h3>Configuration:</h3>
            <ul>
              <li><b>SMTP Host:</b> {}</li>
              <li><b>SMTP Port:</b> {}</li>
              <li><b>Email From:</b> {}</li>
            </ul>

            <p style="color: green;"><b>Everything is working correctly!</b></p>
          </body>
        </html>
        """.format(smtp_host, smtp_port, email_from)

        part1 = MIMEText(text, 'plain')
        part2 = MIMEText(html, 'html')

        msg.attach(part1)
        msg.attach(part2)

        server.send_message(msg)
        server.quit()

        print(f"✅ Test email sent successfully to {smtp_user}")
        print("\n🎉 SUCCESS! Your Gmail SMTP is configured correctly!")
        print("   Check your inbox for the test email.")

        return True

    except smtplib.SMTPAuthenticationError as e:
        print(f"\n❌ Authentication failed!")
        print("   Possible issues:")
        print("   1. App Password is incorrect (check for spaces)")
        print("   2. 2FA is not enabled on your Gmail account")
        print("   3. App Password was not generated properly")
        print(f"\n   Error: {e}")
        return False

    except smtplib.SMTPException as e:
        print(f"\n❌ SMTP error occurred: {e}")
        return False

    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("Gmail SMTP Connection Test")
    print("=" * 50)

    success = test_smtp_connection()

    if success:
        print("\n" + "=" * 50)
        print("Next steps:")
        print("1. Start your backend: uvicorn app.main:app --reload")
        print("2. Start your frontend: cd frontend && npm run dev")
        print("3. Test registration at: http://localhost:3000/auth/register")
        print("=" * 50)
    else:
        print("\n" + "=" * 50)
        print("Please fix the issues above and try again.")
        print("=" * 50)