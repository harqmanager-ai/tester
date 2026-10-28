# DreamHost automatic deployment

The static Harq Media website is prepared for **https://harqtest1.online/**. The workflow at `.github/workflows/deploy-dreamhost.yml` runs on pushes to `main` and can also be started manually on `main`. It uses rsync over SSH; the website has no build step, Node.js runtime, database, or package dependencies.

## Configured destination

| Setting | Value |
| --- | --- |
| SSH host | `iad1-shared-e1-06.dreamhost.com` |
| SSH username | `dh_gv6t5g` |
| SSH port | `22` |
| Website directory | `/home/dh_gv6t5g/harqtest1.online/` |

These non-secret settings are recorded directly in the workflow. No additional host, username, port, or directory secrets are needed.

## Exactly which GitHub secrets to configure

In **harqmanager-ai/tester → Settings → Secrets and variables → Actions → Secrets**, add these two repository secrets:

| Secret | Value to enter securely in GitHub |
| --- | --- |
| `DREAMHOST_SSH_PRIVATE_KEY` | The entire dedicated OpenSSH private key, including its BEGIN/END lines. The matching public key must already be authorised for `dh_gv6t5g` on DreamHost. Use a key that can authenticate unattended; this workflow rejects passphrase-protected keys. |
| `DREAMHOST_KNOWN_HOSTS` | The independently verified OpenSSH `known_hosts` entry for `iad1-shared-e1-06.dreamhost.com`, including hostname, key type, and public server host key. This pins the server identity. A fingerprint by itself is not a `known_hosts` entry. |

Do not commit a private key or place secret values in an issue, pull request, or chat. This setup does not create keys, authorise a public key on DreamHost, or configure the GitHub secret values.

Get the host-key entry from an existing trusted SSH configuration or verify its SHA256 fingerprint against DreamHost's trusted information/support before storing it. A fresh `ssh-keyscan` result alone does not verify the server identity. The workflow never learns or accepts a new host key automatically. If the server's verified host key changes, update the pinned secret after independently confirming that change.

Rsync requires SSH **shell access** for `dh_gv6t5g`, `rsync` on the remote server, and write permission to the existing website directory. SFTP-only access is insufficient. The workflow does not change the DreamHost account, create the website directory, or install software on DreamHost. These prerequisites must be confirmed before enabling deployment.

## Enable automatic deployment after credentials are ready

1. Configure both repository secrets above and ensure the matching public key is authorised on DreamHost.
2. Under the repository's **Settings → Secrets and variables → Actions → Variables**, add **`DREAMHOST_DEPLOY_ENABLED`** with value **`true`**. This is a repository variable, not a secret. Leave it unset or set it to `false` until ready.
3. Push a new change to `main`, or use **Actions → Deploy Harq Media to DreamHost → Run workflow**, selecting `main`.

Saving secrets or changing a variable does not itself trigger deployment. Future pushes to `main` deploy automatically after the enable variable is `true`. Manual runs from other branches are skipped. Unset/false enable flags skip the deployment job; missing or malformed secrets stop the job before any SSH connection. To pause future deployments, set the variable to `false`.

No enable flag or secret values have been configured by this preparation. No deployment or connection to DreamHost has been attempted.

## Upload scope and preservation

`scripts/prepare-site.sh` copies only the existing public website files to a new temporary folder:

```text
index.html
styles.css
script.js
assets/
```

The uploader independently restricts rsync to that same allowlist. It excludes `.git/`, `.github/`, README files, deployment scripts/documentation, and **`.htaccess` at every depth**, including under `assets/`. Those files are never uploaded or overwritten. The existing DreamHost `.htaccess` is preserved.

There is no rsync `--delete` option or remote cleanup command. Existing destination files without a matching uploaded website file remain in place. Files with matching website paths are updated. CSS, JavaScript, and assets are transferred before `index.html`; deployments are not an atomic release. Removed local assets remain on DreamHost until separately cleaned up.

SSH uses the explicitly supplied private key, pinned host-key file, `StrictHostKeyChecking=yes`, and noninteractive public-key authentication. The workflow uses temporary credential files and removes them when its upload step exits. Deployment runs are serialised so an ongoing transfer is not cancelled by a later push.

## Local packaging without deployment

```sh
bash scripts/prepare-site.sh
```

This prints a new temporary folder path and performs no build or network request. An optional output path must be outside the checkout, must not exist, and must have an existing parent directory. Existing folders are never emptied or overwritten.

The uploader also requires both `--deploy` and `DREAMHOST_DEPLOY_ENABLED=true`. Do not run it against DreamHost before the SSH prerequisites are configured. Shell, rsync, and OpenSSH are needed only by the upload machine; the public website itself remains plain HTML, CSS, and JavaScript.
