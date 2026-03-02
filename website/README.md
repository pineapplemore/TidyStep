# TidyStep – Marketing / Support / Privacy (Netlify)

Single-page site for App Store Connect URLs. Deploy this folder to Netlify.

## URLs (one site, same page with anchors)

After deployment, set your Netlify site name (e.g. `tidystep`). Then use:

| Purpose        | URL |
|----------------|-----|
| **Marketing URL** | `https://[your-site-name].netlify.app` |
| **Support URL**   | `https://[your-site-name].netlify.app/#support` |
| **Privacy URL**   | `https://[your-site-name].netlify.app/#privacy` |

Example: if site name is `tidystep`, use  
- Marketing: `https://tidystep.netlify.app`  
- Support: `https://tidystep.netlify.app/#support`  
- Privacy: `https://tidystep.netlify.app/#privacy`

## Deploy on Netlify

1. Log in to [Netlify](https://www.netlify.com/).
2. **Add new site** → **Import an existing project** → connect your Git repo (e.g. GitHub).
3. Build settings (if repo root is CleanHouse):
   - **Build command:** leave empty or `echo 'ok'`
   - **Publish directory:** `website`  
   (Or use the repo root and set Publish directory to `website`; `netlify.toml` in repo root already sets `publish = "website"`.)
4. Deploy. Your site will be at `https://[name].netlify.app`.

If you deploy from the **repo root** and `netlify.toml` is there, Netlify will use `publish = "website"` automatically.

## Edit content

- **Marketing:** top section and “How it works” in `index.html`.
- **Support:** section `id="support"`.
- **Privacy:** section `id="privacy"`. Update the “Last updated” date when you change the policy.
