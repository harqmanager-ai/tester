# Future DreamHost deployment

The website is intended for **harqtest1.online** on standard DreamHost shared hosting. These files prepare a future deployment; they do not connect to DreamHost, configure credentials, or publish anything by themselves.

`dreamhost-deploy.yml.example` is deliberately outside `.github/workflows`, so committing or pushing this repository cannot run it. No repository secrets, variables, environments or DreamHost account settings have been created by this preparation.

## Prepare an upload locally

From the repository root:

```sh
bash scripts/prepare-site.sh
```

The command prints the path to a newly created temporary folder containing only `index.html`, `styles.css`, `script.js` and `assets/`. It performs no compilation and makes no network requests. An optional output-directory argument must name a directory outside the checkout that does not already exist, with an existing parent directory. Existing folders are never overwritten or emptied.

The resulting contents can eventually be uploaded to the existing domain web directory with `index.html` directly inside it. Do not upload the repository's `.git`, documentation, scripts or deployment template.

## Enable automatic deployment later

Do these steps only when the site owner separately authorises deployment:

1. Confirm DreamHost's actual SFTP hostname, website user and exact existing absolute web directory for `harqtest1.online`. Do not assume the hostname is the public domain or that the web directory has its default name.
2. Provision an appropriate deployment SSH key and account access through your normal secure process. This repository supplies no keys or passwords.
3. Independently verify the server's host-key fingerprint with DreamHost. Prepare a matching OpenSSH `known_hosts` entry. Never disable host verification or trust a fresh `ssh-keyscan` result without confirming it independently. A nonstandard SSH port requires the corresponding `[host]:port` entry.
4. In GitHub, configure a `dreamhost` deployment environment and its desired protection/review rules. Supply the future connection inputs below in that environment (or at repository level). The enable flag must instead be a **repository-level** GitHub Actions variable, because GitHub evaluates the job condition before environment-scoped variables are available. None are configured now.
5. Copy `deployment/dreamhost-deploy.yml.example` to `.github/workflows/deploy-dreamhost.yml`, and set the repository variable `DREAMHOST_DEPLOY_ENABLED` to `true` only when ready to allow publication. The copied workflow runs on pushes to `main` and manual dispatches; its deployment job is skipped unless that variable is exactly `true`.

### Future GitHub inputs

| Type | Name | Purpose |
| --- | --- | --- |
| Repository variable | `DREAMHOST_DEPLOY_ENABLED` | Must be exactly `true` to permit deployment; leave unset while inactive. Environment-scoped placement will not enable the job. |
| Variable | `DREAMHOST_HOST` | DreamHost-provided SFTP server hostname. |
| Variable | `DREAMHOST_USER` | Website's SFTP username. |
| Variable | `DREAMHOST_WEB_ROOT` | Exact existing absolute directory serving `harqtest1.online`. |
| Variable | `DREAMHOST_PORT` | Optional SFTP port; defaults to `22`. |
| Variable | `DREAMHOST_KNOWN_HOSTS` | Independently verified OpenSSH server host-key entry. This is a public host key, not a private credential. |
| Secret | `DREAMHOST_SSH_PRIVATE_KEY` | Deployment private key, added securely in GitHub later. Never commit it. The unattended template expects a key usable without an interactive passphrase prompt. |

The uploader uses OpenSSH SFTP, including accounts that do not have remote shell access. It requires both `--deploy` and `DREAMHOST_DEPLOY_ENABLED=true`. Host-key checking remains strict, and password prompts are disabled. It uploads CSS, JavaScript and assets before the homepage and never deletes existing remote files. Uploads are not an atomic release; keep a hosting backup before enabling real deployments. Removed local assets remain on the server until deliberately cleaned up.

Shell and OpenSSH are needed only on the upload machine or GitHub runner. The website itself needs no Node.js, package installation, build process, server application or database. No deployment test has connected to DreamHost.
