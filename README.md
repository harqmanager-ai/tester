# Harq Media

A lightweight, responsive website for **Harq Media**, prepared for standard DreamHost shared hosting at **harqtest1.online**. The primary brand colour is **#6E7B8E**, with white backgrounds and system typography.

The complete homepage is `index.html`, including navigation, hero, About, Services, approach, and Contact sections. No Node.js runtime, package installation, build step, database, framework, external API, or WordPress is required.

## Files

- `index.html` — homepage content and project enquiry dialog.
- `styles.css` — layout, responsive styles, and brand colours.
- `script.js` — mobile navigation and email enquiry interactions.
- `assets/` — locally hosted website images.
- `scripts/` — optional local packaging and future deployment helpers; not part of the public website.
- `deployment/` — inactive DreamHost deployment template and instructions; not part of the public website.

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

When deployment is separately authorised, upload only these website files to the domain's existing, verified web directory:

```text
index.html
styles.css
script.js
assets/
  favicon.svg
  hero.jpg
```

Keep `index.html` directly inside the web directory. Verify the actual directory in the DreamHost account rather than assuming a server path from the domain name. Keep `.git/`, `README.md`, `scripts/`, `deployment/`, and credentials outside the public web directory.

No Node.js process, database, or WordPress installation is needed. Future changes can be uploaded as updated static files.

## Future automatic deployment — inactive

The optional [DreamHost deployment preparation](deployment/README.md) packages only public website files and provides an inactive GitHub Actions template for a future SFTP deployment. Packaging copies the existing static files; it is optional and does not compile or build the website.

**No deployment credentials or repository secrets have been configured. No deployment workflow is active, and pushing this repository does not publish the website.** The template is stored outside `.github/workflows/` so that it cannot run until deliberately enabled in a future deployment task. No DreamHost account changes are part of this setup.

GitHub Pages is not used. Its previous `.nojekyll` marker has been removed; there is no Pages workflow or domain configuration.

## Customise

- Edit page copy and section links in `index.html`.
- Change the primary brand colour (`#6E7B8E`) in `styles.css`.
- Replace local images in `assets/` and update their alternative text in `index.html`.
- Verify or replace `hello@harqmedia.com` wherever it appears in `index.html` and `script.js` before publishing. This is a suggested contact address; the repository does not configure or verify an inbox.

Contact links and the enquiry dialog compose a message in the visitor's email application. They do not send or store messages on a server; the visitor must send the email themselves. Configure a working email account separately in your hosting or email provider.

---

Original repository description: Harq Test.
