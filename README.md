# Helm Chart Repository

This repository contains multiple Helm charts for common applications.

## 📦 Available Charts

### 1. **nginx-app** (v1.0.0)

A simple Nginx web application deployment

- **App Version**: 1.25.0
- **Features**: Deployment, Service, configurable replicas, resource limits

### 2. **redis-cache** (v2.0.0)

Redis cache deployment with optional persistence

- **App Version**: 7.0
- **Features**: Deployment, Service, PersistentVolumeClaim, configurable memory policies

### 3. **postgres-db** (v1.5.0)

PostgreSQL database deployment

- **App Version**: 15.3
- **Features**: Deployment, Service, PersistentVolumeClaim, configurable database settings

## 🚀 Using These Charts

### Add the Repository

```bash
helm repo add my-charts https://shared-infrastructure.github.io/helm-utils/
helm repo update
```

### Install a Chart

```bash
# Install nginx-app
helm install my-nginx my-charts/nginx-app

# Install redis-cache
helm install my-redis my-charts/redis-cache

# Install postgres-db
helm install my-postgres my-charts/postgres-db
```

### Install with Custom Values

```bash
helm install my-nginx my-charts/nginx-app --set replicaCount=3
```

Or create a custom `values.yaml` file:

```bash
helm install my-nginx my-charts/nginx-app -f custom-values.yaml
```

### Search Available Charts

```bash
helm search repo my-charts
```

## 🔧 Development

### Repository Structure

```
.
├── charts/                  # Source charts
│   ├── nginx-app/
│   ├── redis-cache/
│   └── postgres-db/
├── docs/                    # Packaged charts and index
│   ├── index.yaml
│   ├── nginx-app-1.0.0.tgz
│   ├── redis-cache-2.0.0.tgz
│   └── postgres-db-1.5.0.tgz
└── README.md
```

### Modifying Charts

1. Edit the chart in the `charts/` directory
2. Update the version in `Chart.yaml`
3. Package the chart:
   ```bash
   helm package charts/CHART_NAME -d docs/
   ```
4. Update the repository index:
   ```bash
   helm repo index docs/ --url https://shared-infrastructure.github.io/helm-utils/
   ```
5. Commit and push changes

### Adding New Charts

1. Create a new chart:
   ```bash
   helm create charts/new-chart
   ```
2. Customize the chart templates and values
3. Package and index as described above

## 📝 Publishing Instructions

### Option 1: GitHub Pages (Recommended)

1. **Initialize Git Repository**

   ```bash
   git init
   git add .
   git commit -m "Initial commit: Helm repository"
   ```

2. **Create GitHub Repository**

   - Go to GitHub and create a new repository named `helm-utils`
   - Don't initialize with README (we already have one)

3. **Push to GitHub**

   ```bash
   git remote add origin https://github.com/Shared-Infrastructure/helm-utils.git
   git branch -M main
   git push -u origin main
   ```

4. **Enable GitHub Pages**

   - Go to repository Settings → Pages
   - Under "Source", select branch: `main`
   - Select folder: `/docs`
   - Click Save
   - GitHub Pages will be available at: `https://shared-infrastructure.github.io/helm-utils/`

5. **Update index.yaml URL**

   - After enabling GitHub Pages, if you used a placeholder username, regenerate the index:
     ```bash
     helm repo index docs/ --url https://shared-infrastructure.github.io/helm-utils/
     git add docs/index.yaml
     git commit -m "Update index.yaml with correct URL"
     git push
     ```

6. **Test Your Repository**
   ```bash
   helm repo add my-charts https://shared-infrastructure.github.io/helm-utils/
   helm repo update
   helm search repo my-charts
   ```

### Option 2: ChartMuseum (Self-Hosted)

1. **Install ChartMuseum**

   ```bash
   # Using Helm
   helm repo add chartmuseum https://chartmuseum.github.io/charts
   helm install chartmuseum chartmuseum/chartmuseum \
     --set env.open.DISABLE_API=false \
     --set persistence.enabled=true
   ```

2. **Upload Charts**

   ```bash
   # Install Helm plugin
   helm plugin install https://github.com/chartmuseum/helm-push

   # Add your ChartMuseum repository
   helm repo add my-repo http://localhost:8080

   # Push charts
   helm cm-push charts/nginx-app/ my-repo
   helm cm-push charts/redis-cache/ my-repo
   helm cm-push charts/postgres-db/ my-repo
   ```

### Option 3: Artifact Hub

1. **Publish to GitHub Pages** (as described in Option 1)

2. **Register on Artifact Hub**

   - Go to https://artifacthub.io/
   - Sign in with GitHub
   - Add your repository
   - Provide the repository URL: `https://shared-infrastructure.github.io/helm-utils/`

3. **Add Repository Metadata** (Optional)
   Create `docs/artifacthub-repo.yml`:
   ```yaml
   repositoryID: shared-infrastructure-helm-utils
   owners:
     - name: Brian Kim
       email: kimhiepninh02121997@gmail.com
   ```

### Option 4: Harbor Registry

1. **Set up Harbor** (if not already available)

2. **Upload Charts via UI**

   - Log into Harbor
   - Navigate to your project
   - Click on "Helm Charts"
   - Upload the `.tgz` files from the `docs/` directory

3. **Add Repository**
   ```bash
   helm repo add harbor https://harbor.example.com/chartrepo/PROJECT_NAME \
     --username USERNAME \
     --password PASSWORD
   ```

### Option 5: Amazon S3 / Cloud Storage

1. **Create an S3 Bucket**

   - Make it public or use appropriate access policies
   - Enable static website hosting

2. **Upload Charts**

   ```bash
   aws s3 sync docs/ s3://your-bucket-name/ --acl public-read
   ```

3. **Add Repository**
   ```bash
   helm repo add my-charts https://your-bucket-name.s3.amazonaws.com/
   ```

## 🔄 Continuous Integration

### GitHub Actions Workflow

Create `.github/workflows/release.yml`:

```yaml
name: Release Charts

on:
  push:
    branches:
      - main

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Configure Git
        run: |
          git config user.name "$GITHUB_ACTOR"
          git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

      - name: Install Helm
        uses: azure/setup-helm@v3

      - name: Package Helm Charts
        run: |
          for chart in charts/*; do
            helm package "$chart" -d docs/
          done

      - name: Generate Index
        run: |
          helm repo index docs/ --url https://${{ github.repository_owner }}.github.io/${{ github.event.repository.name }}/

      - name: Commit and Push
        run: |
          git add docs/
          git diff --quiet && git diff --staged --quiet || git commit -m "Update Helm charts [skip ci]"
          git push
```

## 📊 Repository Metadata

The `index.yaml` file contains metadata about all charts in this repository:

- Chart name and version
- Application version
- Description and keywords
- Download URLs
- Checksums for integrity verification

## 🛠️ Maintenance

### Updating Chart Versions

When you update a chart:

1. Increment the version in `charts/CHART_NAME/Chart.yaml`
2. Package the chart: `helm package charts/CHART_NAME -d docs/`
3. Update the index: `helm repo index docs/ --url https://shared-infrastructure.github.io/helm-utils/`
4. Commit and push: `git add . && git commit -m "Release CHART_NAME vX.Y.Z" && git push`

### Deprecating Charts

To mark a chart as deprecated, add to `Chart.yaml`:

```yaml
deprecated: true
```

Then repackage and update the index.

## 📚 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Artifact Hub](https://artifacthub.io/)
- [ChartMuseum Documentation](https://chartmuseum.com/docs/)

## 📄 License

MIT License - Feel free to use these charts in your projects.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

**Maintainer**: Brian Kim (kimhiepninh02121997@gmail.com)
**Organization**: [Shared-Infrastructure](https://github.com/Shared-Infrastructure)
