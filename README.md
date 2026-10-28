# Harq Media

A lightweight, responsive website built with HTML, CSS, and JavaScript. No framework, package installation, build step, external API, or WordPress is required.

## Files

- `index.html` — homepage content and project enquiry dialog.
- `styles.css` — layout, responsive styles, and brand colours.
- `script.js` — mobile navigation and email enquiry interactions.
- `assets/` — locally hosted website images.

The architectural hero image is generated artwork, hosted locally as an optimised JPEG. Fonts are supplied by the visitor’s system, and icons are inline SVGs, so the site makes no third-party requests.

## Preview locally

Open `index.html` in a browser, or serve the folder with Python:

```sh
cd /workspace/tester
python3 -m http.server 8000
```

Then open `http://localhost:8000` in your browser. Stop the server with `Ctrl+C`.

## Host on DreamHost

1. Add your domain as a fully hosted website in the DreamHost panel and enable HTTPS.
2. Connect with SFTP using your DreamHost website user.
3. Upload `index.html`, `styles.css`, `script.js`, and the entire `assets/` folder to the domain's configured web directory, keeping `index.html` directly inside that directory.
4. Visit your domain and check the navigation, mobile layout, images, and contact links.

No Node.js process, database, or WordPress installation is needed. Future changes can be uploaded as updated static files.

## Customise

- Edit page copy and section links in `index.html`.
- Change the primary brand colour (`#6E7B8E`) in `styles.css`.
- Replace local images in `assets/` and update their alternative text in `index.html`.
- Verify or replace `hello@harqmedia.com` wherever it appears in `index.html` and `script.js` before publishing. This is a suggested contact address; the repository does not configure or verify an inbox.

Contact links and the enquiry dialog compose a message in the visitor's email application. They do not send or store messages on a server; the visitor must send the email themselves. Configure a working email account separately in your hosting or email provider.

---

Original repository description: Harq Test.
