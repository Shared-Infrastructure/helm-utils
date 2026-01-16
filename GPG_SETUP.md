# GPG Signing Setup for GitHub Actions

This guide explains how to configure GPG signing for automated Helm chart releases.

## 🔐 Overview

The GitHub Actions workflow can automatically sign Helm charts with your GPG key. This is **optional** - if not configured, charts will be packaged without signatures.

## 📋 Prerequisites

1. GPG key generated locally (you already have this!)
2. GitHub repository with admin access
3. Your GPG key details:
   - Key ID: `5E53C789B3521AE765C9F052543DA541AF147BCC`
   - Key name: `brian-gpg-key`
   - Email: `brian.kim@nab.com.au`

## 🔑 Step 1: Export Your Private Key

**⚠️ WARNING**: Your private key is sensitive! Keep it secure.

```bash
# Export your private key (you'll be prompted for passphrase)
gpg --armor --export-secret-keys brian.kim@nab.com.au > private-key.asc

# View the exported key (starts with -----BEGIN PGP PRIVATE KEY BLOCK-----)
cat private-key.asc
```

## 🌐 Step 2: Add GitHub Secrets

Go to your GitHub repository:

1. Navigate to: **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add these three secrets:

### Secret 1: `GPG_PRIVATE_KEY`

- **Name**: `GPG_PRIVATE_KEY`
- **Value**: Paste the entire contents of `private-key.asc` including the `-----BEGIN PGP PRIVATE KEY BLOCK-----` and `-----END PGP PRIVATE KEY BLOCK-----` lines

### Secret 2: `GPG_PASSPHRASE`

- **Name**: `GPG_PASSPHRASE`
- **Value**: Your GPG key passphrase (leave empty if you didn't set one)

### Secret 3: `GPG_KEY_NAME`

- **Name**: `GPG_KEY_NAME`
- **Value**: `brian-gpg-key` (or `brian.kim@nab.com.au`)

## 🧹 Step 3: Clean Up

After uploading to GitHub:

```bash
# IMPORTANT: Delete the exported private key from your computer
rm private-key.asc

# Verify it's gone
ls -la private-key.asc  # Should show "No such file or directory"
```

## ✅ Step 4: Test the Workflow

```bash
# Make a small change to trigger the workflow
# (The workflow triggers on changes to charts/)
echo "# Test change" >> charts/nginx-app/README.md

# Commit and push
git add charts/nginx-app/README.md
git commit -m "Test GPG signing workflow"
git push origin main
```

Then:

1. Go to **Actions** tab on GitHub
2. Watch the "Release Charts" workflow run
3. Check that charts are signed (should see `.tgz.prov` files)

## 📝 How It Works

### With GPG Secrets Configured:

```
charts/nginx-app/ → nginx-app-1.0.0.tgz + nginx-app-1.0.0.tgz.prov (signed!)
                  → gpg-public-key.asc (exported automatically)
```

### Without GPG Secrets:

```
charts/nginx-app/ → nginx-app-1.0.0.tgz (unsigned)
```

## 🔍 Verify Signing is Working

After the workflow runs, check your `docs/` folder:

```bash
# Pull the changes
git pull

# List files - should see .prov files
ls -la docs/

# Should see:
# - *.tgz files (charts)
# - *.tgz.prov files (signatures)
# - gpg-public-key.asc (public key)
```

## 🛡️ Security Best Practices

### ✅ DO:

- Store private keys only in GitHub Secrets (encrypted)
- Use a strong passphrase for your GPG key
- Regularly rotate keys (every 1-3 years)
- Keep your private key backed up securely offline

### ❌ DON'T:

- Commit private keys to git
- Share private keys via email/Slack
- Use keys without passphrases in production
- Store private keys in plain text files

## 🚫 To Disable Signing

If you want to disable automatic signing:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Delete the `GPG_PRIVATE_KEY`, `GPG_PASSPHRASE`, and `GPG_KEY_NAME` secrets
3. The workflow will automatically fall back to unsigned packaging

## 🆘 Troubleshooting

### Workflow fails with "gpg: signing failed"

- Check that `GPG_PASSPHRASE` is correct
- Verify `GPG_KEY_NAME` matches your key name or email
- Check GitHub Actions logs for specific error messages

### Charts are not signed

- Verify secrets are set correctly in GitHub Settings
- Check that secret names match exactly (case-sensitive)
- Look at workflow logs to see if the import step succeeded

### "No secret key" error

- Ensure `GPG_PRIVATE_KEY` contains the PRIVATE key, not public key
- It should start with `-----BEGIN PGP PRIVATE KEY BLOCK-----`

## 📚 Additional Resources

- [Helm Provenance Documentation](https://helm.sh/docs/topics/provenance/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GPG Documentation](https://gnupg.org/documentation/)

## 🎓 For Learning

Since this is a learning project, signing is **optional**. You can:

- ✅ Try setting it up to learn about GPG in CI/CD
- ✅ Skip it and package locally with signing instead
- ✅ Use unsigned charts (perfectly fine for development)

The workflow works either way! 🎉
