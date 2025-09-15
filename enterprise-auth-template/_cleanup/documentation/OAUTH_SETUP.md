# OAuth Provider Configuration Guide

This guide provides step-by-step instructions for configuring OAuth authentication with Google, GitHub, and Discord providers in the Enterprise Authentication Template.

## Quick Setup Overview

1. Create OAuth applications with each provider
2. Configure environment variables in `backend/.env.dev`
3. Start the development servers
4. Test the OAuth flow

## Provider Configuration

### Google OAuth Setup

1. **Create Google OAuth Application**:
   - Visit [Google Cloud Console](https://console.developers.google.com/)
   - Create a new project or select an existing one
   - Navigate to "Credentials" → "Create Credentials" → "OAuth 2.0 Client IDs"
   - Application type: "Web application"
   - Authorized redirect URIs: `http://localhost:3000/auth/callback/google`

2. **Configuration**:
   ```bash
   GOOGLE_CLIENT_ID=your_google_client_id_here
   GOOGLE_CLIENT_SECRET=your_google_client_secret_here
   ```

### GitHub OAuth Setup

1. **Create GitHub OAuth App**:
   - Visit [GitHub Developer Settings](https://github.com/settings/applications/new)
   - Application name: "Enterprise Auth Template (Dev)"
   - Homepage URL: `http://localhost:3000`
   - Authorization callback URL: `http://localhost:3000/auth/callback/github`

2. **Configuration**:
   ```bash
   GITHUB_CLIENT_ID=your_github_client_id_here
   GITHUB_CLIENT_SECRET=your_github_client_secret_here
   ```

### Discord OAuth Setup

1. **Create Discord Application**:
   - Visit [Discord Developer Portal](https://discord.com/developers/applications)
   - Click "New Application" and give it a name
   - Navigate to "OAuth2" → "General"
   - Add redirect: `http://localhost:3000/auth/callback/discord`
   - Under "OAuth2" → "URL Generator", select scopes: `identify`, `email`

2. **Configuration**:
   ```bash
   DISCORD_CLIENT_ID=your_discord_client_id_here
   DISCORD_CLIENT_SECRET=your_discord_client_secret_here
   ```

## Environment Configuration

Add the following variables to your `backend/.env.dev` file:

```bash
# OAuth Configuration
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
GITHUB_CLIENT_ID=your_github_client_id_here
GITHUB_CLIENT_SECRET=your_github_client_secret_here
DISCORD_CLIENT_ID=your_discord_client_id_here
DISCORD_CLIENT_SECRET=your_discord_client_secret_here

# OAuth Redirect URLs (for development)
OAUTH_REDIRECT_URL=http://localhost:3000/auth/callback
```

## Testing OAuth Flow

### Automated Testing

Run the OAuth test script to verify API endpoints:

```bash
# From project root
chmod +x test_oauth.sh
./test_oauth.sh
```

This script will:
- Test OAuth initialization endpoints for all providers
- Verify authorization URL generation
- Display configuration instructions

### Manual Testing

1. **Start the development servers**:
   ```bash
   # Backend
   cd backend && uvicorn app.main:app --reload

   # Frontend (in new terminal)
   cd frontend && npm run dev
   ```

2. **Test the flow**:
   - Visit `http://localhost:3000/auth/login`
   - Click on Google/GitHub/Discord login buttons
   - Complete the OAuth authorization
   - Verify successful authentication and redirect

### Expected Behavior

✅ **Successful OAuth Flow**:
1. Click provider button → redirect to provider&apos;s authorization page
2. User authorizes the application
3. Provider redirects back with authorization code
4. Backend exchanges code for user information
5. User is authenticated and redirected to dashboard

❌ **Common Issues**:
- **Invalid redirect URI**: Check redirect URLs in provider settings
- **Client credentials error**: Verify CLIENT_ID and CLIENT_SECRET
- **Scope permissions**: Ensure required scopes are configured

## API Endpoints

The OAuth implementation provides these endpoints:

- `GET /api/v1/oauth/{provider}/init` - Initialize OAuth flow
- `POST /api/v1/oauth/{provider}/callback` - Handle OAuth callback
- `GET /api/v1/oauth/providers` - List available providers

## Security Considerations

### State Parameter
- Each OAuth request includes a unique `state` parameter for CSRF protection
- State is validated on callback to prevent request forgery

### Redirect URL Validation
- All redirect URLs must be explicitly configured in provider settings
- Never use dynamic or user-provided redirect URLs

### Token Handling
- OAuth tokens are exchanged server-side only
- User session uses standard JWT tokens, not provider tokens
- Provider tokens can be stored for API access if needed

## Production Configuration

For production deployment:

1. **Update redirect URLs** to use your production domain:
   ```
   https://yourdomain.com/auth/callback/google
   https://yourdomain.com/auth/callback/github  
   https://yourdomain.com/auth/callback/discord
   ```

2. **Use production environment variables**:
   ```bash
   # In production .env file
   OAUTH_REDIRECT_URL=https://yourdomain.com/auth/callback
   ```

3. **Enable HTTPS only**:
   - All OAuth providers require HTTPS in production
   - Configure SSL certificates and secure headers

## Troubleshooting

### Common Error Messages

**"OAuth initialization failed: 400"**
- Check if CLIENT_ID and CLIENT_SECRET are properly set
- Verify the provider is enabled in your OAuth app settings

**"Invalid redirect_uri parameter"**
- Ensure the redirect URI in provider settings matches exactly
- Check for trailing slashes or protocol mismatches

**"Access denied"**
- User declined authorization
- Check if your app is properly configured with required scopes

### Debug Mode

Enable OAuth debugging by setting:
```bash
LOG_LEVEL=DEBUG
```

This will provide detailed logs of the OAuth flow for troubleshooting.

## Support

For additional help:
- Check the provider-specific documentation linked above
- Review the backend OAuth service implementation in `backend/app/services/oauth_service.py`
- Test endpoints using the provided test script

---

**Note**: Remember to keep your client secrets secure and never commit them to version control. Use environment variables for all sensitive configuration.