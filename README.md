# Web2APK — GitHub Pages + GitHub Actions APK Builder

Web2APK is a static GitHub Pages UI that packages HTML/web applications as Android APKs. The GitHub Pages site itself does **not** pretend to run the Android SDK in the browser. Instead, it uploads a build request to a builder repository and dispatches a GitHub Actions workflow that runs the real Android/Gradle toolchain.

## Repo

https://github.com/tbenitz/web2apk

After enabling Pages (Settings → Pages → Deploy from branch `main` / `/`), the UI will be at:

https://tbenitz.github.io/web2apk/

## What it supports

- A single `.html` file.
- A ZIP containing a complete static site.
- A ZIP containing an npm web project with `package.json`; the workflow can run `npm ci`/`npm install`, then `npm run build` (or custom commands).
- A website URL for best-effort static mirroring.
- An existing source path already committed to the builder repository.
- Android app name, package id, version, orientation, icon, fullscreen, keep-awake and media-autoplay settings.
- Optional INTERNET permission and remote navigation.
- Offline dependency mirroring for ordinary scripts, stylesheets, fonts, images, media, CSS URLs, static ES-module imports, and obvious static fetches such as `.json`, `.wasm`, `.onnx`, and other model/data files.
- Strict offline mode that fails when critical network references or missing packaged files remain.
- Installable debug APK on every successful build.
- Optional signed release APK when release-signing secrets are configured.
- Build and offline reports returned beside the APK.

## Important boundary

This wraps **web applications**. It cannot generically translate a Windows EXE, macOS application, iOS binary, or arbitrary native desktop program into Android machine code.

Also, copying a web front end does not magically reproduce a backend. Apps that require remote APIs, login servers, streaming services, cloud databases, server-side rendering, live sockets, or other server logic need app-specific changes before they can be truly offline.

## Recommended repository layout

You can use one repository for both the GitHub Pages UI and the builder, but browser-uploaded source will be committed to that repository while a build runs.

For private/proprietary apps, the safer layout is:

1. **Public UI repo** — hosts `index.html`, `app.js`, and `styles.css` with GitHub Pages.
2. **Private builder repo** — contains this full project including `.github/workflows`, `scripts`, and `android-template`.
3. In the Web2APK page, enter the private builder repo owner/name and a fine-grained token authorized only for that repo.

The page's “cleanup temporary input files” option deletes the temporary files after a successful build, but **Git deletion does not erase old commits/history**. Do not use a public builder repo for source you need to keep private.

## Quick setup

1. Enable GitHub Pages from this repository: **Settings → Pages → Deploy from a branch → `main` / root**.
2. Create a **fine-grained personal access token** limited to this repository with:
   - **Contents: Read and write**
   - **Actions: Read and write**
3. Open https://tbenitz.github.io/web2apk/ , enter owner `tbenitz`, repo `web2apk`, and the token, then press **Test connection**.
4. Choose HTML/ZIP, URL, or an existing repository path.
5. Set your Android package name and offline options.
6. Press **Build Android APK**. The page dispatches Actions, follows the run, downloads the artifact, and extracts the APK in the browser.

The token can be kept in `sessionStorage` for the current browser tab. It is not placed in the generated app or committed by Web2APK.

## Debug APK vs release APK

The default workflow always builds a normal Android **debug APK**. It is signed with Gradle's debug signing key and can be sideloaded for testing.

For a stable release APK that can be updated later with the same signing identity, create and safely keep your own JKS keystore, then add these repository Actions secrets:

- `ANDROID_KEYSTORE_B64` — base64-encoded contents of the `.jks`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Example keystore creation on a machine with a JDK:

```bash
keytool -genkeypair -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias web2apk
```

Encode it for the GitHub secret:

```bash
base64 < release.jks | tr -d '\n'
```

**Back up the keystore and passwords.** Android app updates must be signed consistently.

## How the Android wrapper works

The workflow generates a small native Java Android app. Web files are compiled into the APK's `assets/` directory. The app uses `WebViewAssetLoader` on the reserved `appassets.androidplatform.net` domain, JavaScript/DOM storage support, browser back navigation, external intent handling, file-picker support, and optional network permission.

The project currently uses:

- Java 17
- Gradle 8.13
- Android Gradle Plugin 8.13.0
- compile/target SDK 35
- AndroidX WebKit 1.17.0
- minimum supported API 24

## Offline mirroring

Three modes are available:

- **Mirror** — download/rewrite supported remote static dependencies, then build even if the report finds remaining network-dependent behavior.
- **Strict offline** — mirror supported dependencies and fail when downloads fail or critical remote references remain.
- **Keep online** — preserve external URLs and skip mirroring.

## Security notes

- Prefer fine-grained tokens restricted to one builder repository.
- Do not hard-code a token into `app.js`.
- Do not commit a release keystore.
- Use a private builder repository for private app source.
- Treat untrusted uploaded HTML/ZIPs as untrusted code. npm build scripts execute inside the GitHub Actions runner for that job.

## License

MIT. See `LICENSE`.
