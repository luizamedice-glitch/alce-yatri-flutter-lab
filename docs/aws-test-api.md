# AWS test API — Android clients

Test endpoint: `https://54-94-146-177.sslip.io`

The API is protected by Caddy HTTP Basic authentication. **Never commit the password, the Caddy password hash, SSH keys, or APKs with embedded credentials.**

The username defaults to `alce-teste`; enter the password in each app at runtime. The server operator can view the generated credentials locally using `sudo cat /root/alce-api-credentials`. Do not share that output or take screenshots of it.

After GitHub Actions successfully builds both clients, download and install the new debug APK artifacts. Open each app and authenticate using the same lab account. Request a ride in the passenger app, go online in the driver app, accept the ride, arrive, start, and complete it. Both apps poll the shared mock backend every three seconds.

The mock server stores only one ride in memory; restarting the Node.js process clears it. This environment has no real driver identity, rider identity, matching, persistent data, payment processing, or production security. HTTP Basic authentication is only a temporary lab gate. Replace it with individual identities and scoped tokens before any real use.

Ensure Lightsail allows TCP 80/443, not public TCP 8080. Backend listens on loopback. Protect the SSH key and restrict port 22 to trusted source addresses where possible.

Original APK integration and the opt-in Giselo driver fixture are tracked in
[original-apks-integration.md](original-apks-integration.md). That work does not
establish that the original APKs are connected to this deployment.
