# AI Tools Troubleshooting

## CodeCompanion Issues

### API Key Problems
```bash
# Check environment variable
echo $OPENAI_API_KEY

# Test API connectivity
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models

# Set API key temporarily
:lua vim.env.OPENAI_API_KEY = "your-key-here"
```

### Chat Not Responding
```bash
# Check network
ping api.openai.com

# Restart CodeCompanion
:CodeCompanion reset
```

## GitHub Copilot Issues

### Authentication Problems
```bash
# Check status
:Copilot status

# Re-authenticate
:Copilot auth

# Check logs
:Copilot log
```

### Suggestions Not Appearing
```bash
# Enable Copilot
:Copilot enable

# Check file type status
:Copilot status

# Manual trigger: Ctrl+] in insert mode
```

## NeoCodeium Issues

### Setup Problems
```bash
# Check status
:NeoCodeium status

# Re-authenticate
:NeoCodeium auth

# Check config
:lua print(vim.inspect(require("neocodeium").config))
```

## Database (Dbee) Issues

### Connection Failures
```bash
# Check dbee status
:Dbee

# Load connections manually
:DbeeLoadConnections

# Check connection file
cat ~/.cache/nvim/dbee/persistence.json
```

### Snowflake MFA Problems
```bash
# Disable auto-connect
:lua require("config.dbee-helpers").disable_snowflake_autoconnect()

# Restore when needed
:DbeeRestoreSnowflake
```
