# Harq Media

A lightweight, responsive website for **Harq Media**, prepared for standard DreamHost shared hosting at **harqtest1.online**. The primary brand colour is **#6E7B8E**, with white backgrounds and system typography.

The complete homepage is `index.html`, including navigation, hero, About, Services, approach, and Contact sections. No Node.js runtime, package installation, build step, database, framework, external API, or WordPress is required.

## Files

- `index.html` — homepage content and project enquiry dialog.
- `styles.css` — layout, responsive styles, and brand colours.
- `script.js` — mobile navigation and email enquiry interactions.
- `assets/` — locally hosted website images.
- `scripts/` — local packaging and guarded rsync deployment helpers; not part of the public website.
- `.github/workflows/deploy-dreamhost.yml` — automatic deployment workflow, gated until credentials are ready.
- `deployment/` — DreamHost setup and secret instructions; not part of the public website.

The architectural hero image is generated artwork, hosted locally as an optimised JPEG. Fonts are supplied by the visitor’s system, and icons are inline SVGs, so the site makes no third-party requests.

## Preview locally

Open `index.html` in a browser, or serve the folder with Python:

```sh
cd /workspace/tester
python3 -m http.server 8000
```

Then open `http://localhost:8000` in your browser. Stop the server with `Ctrl+C`.

## DreamHost hosting target

The intended website address is **https://harqtest1.online/**. This repository does not configure the domain, DNS, SSL certificates, hosting account, or email, and does not establish that the website is currently published.

The deployment workflow targets `/home/dh_gv6t5g/harqtest1.online/` on `iad1-shared-e1-06.dreamhost.com` over SSH port `22` as `dh_gv6t5g`. It uploads only these website files:

```text
index.html
styles.css
script.js
assets/
  favicon.svg
  hero.jpg
```

Keep `index.html` directly inside the web directory. The workflow keeps `.git/`, `.github/`, README files, `scripts/`, `deployment/`, and credentials outside the public web directory. It preserves the existing `.htaccess` and does not delete existing server files.

No Node.js process, database, or WordPress installation is needed. Future changes can be uploaded as updated static files.

## Automatic deployment — awaiting credentials

The [DreamHost deployment instructions](deployment/README.md) describe the GitHub Actions workflow and secure SSH setup. It uses **rsync over SSH** on pushes to `main`, with no website build step. Packaging only copies the existing static files.

Configure the two repository secrets **`DREAMHOST_SSH_PRIVATE_KEY`** and **`DREAMHOST_KNOWN_HOSTS`**, then set the repository variable **`DREAMHOST_DEPLOY_ENABLED=true`** only after SSH authentication is ready. Leave that variable unset or false until then. Without it, the deployment job is skipped; missing or malformed secrets stop it before any SSH connection.

**No credentials or enable flag have been configured, no DreamHost connection/deployment has been attempted, and no DreamHost account settings have been changed by this preparation.** After setup, a new push to `main` or a manual workflow run on `main` starts deployment. See [deployment/README.md](deployment/README.md) for the exact secret values required, SSH shell/remote-rsync prerequisites, and preservation rules.

GitHub Pages is not used. Its previous `.nojekyll` marker has been removed; there is no Pages workflow or domain configuration.

## Customise

- Edit page copy and section links in `index.html`.
- Change the primary brand colour (`#6E7B8E`) in `styles.css`.
- Replace local images in `assets/` and update their alternative text in `index.html`.
- Verify or replace `hello@harqmedia.com` wherever it appears in `index.html` and `script.js` before publishing. This is a suggested contact address; the repository does not configure or verify an inbox.

Contact links and the enquiry dialog compose a message in the visitor's email application. They do not send or store messages on a server; the visitor must send the email themselves. Configure a working email account separately in your hosting or email provider.

---

Original repository description: Harq Test.
