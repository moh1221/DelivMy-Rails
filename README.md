# DelivMy Rails

A Rails website and the JSON backend for [DelivMyApp](https://github.com/moh1221/DelivMyApp). A signed-in user can post a request, browse available requests from others, or accept a delivery.

## Run locally

This project targets **Ruby 4.0.10**, **Rails 8.1.4.1**, and **Bootstrap 5.3.9**. Development and test use SQLite. No external accounts or keys are required for the core workflow.

```sh
gem install bundler -v 4.0.20
BUNDLE_WITHOUT=production bin/setup
BUNDLE_WITHOUT=production bin/rails server -b 127.0.0.1
```

Open `http://127.0.0.1:3000`, create an account, and sign in. Use a second account to search for and accept a request. The request form accepts a pickup address and coordinates manually or from device location; an optional restricted `GOOGLE_MAPS_BROWSER_KEY` enables maps and address geocoding.

Development mail is written to `tmp/mail`. Development avatars and databases are in `storage/`. If upgrading a local database from the legacy default, back up the SQLite database under `db/` and configure `DATABASE_URL` to point at your local copy before running migrations.

## Tests

```sh
BUNDLE_WITHOUT=production bin/rails zeitwerk:check
BUNDLE_WITHOUT=production bin/rails test
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 BUNDLE_WITHOUT=production bin/rails assets:precompile
```

The integration tests exercise the mobile JSON routes, browser sign-in and CSRF protection, password-reset revocation, privacy and ownership rules, distinct courier acceptance, and avatar upload and serving. GitHub Actions also runs the API tests against the mysql2 adapter with MySQL 8.4.

## Mobile API contract

Send `Accept: application/json`; JSON mutations also send `Content-Type: application/json`. The Rails `.json` URL suffix is supported.

- `POST /login` with `{"session":{"email":"…","password":"…"}}` returns `{"session":{"id":"…","user_id":"…"}}`. Treat `session.id` as a secret; send it as `Authorization: Bearer <token>` on each native request. Do not store it in plain preferences or log it.
- `DELETE /logout` invalidates that session and returns 204. Tokens expire; clients should sign in again on 401.
- `GET /requests` returns the user's requests; `POST /requests` accepts a `request` object with the established field names (including `PlaceName`, `items_attributes`, and `location_attributes`), returns 201, and uses the current user as owner. `DELETE /requests/:id` returns 204 for the owner of an unassigned request. A request cannot be deleted after acceptance.
- `GET /search?sw=lat,long&ne=lat,long&center=lat,long` returns up to 100 open results from other users; the existing `center` parameter is accepted but not needed for bounding-box search. Listed coordinates are rounded and pickup address withheld until acceptance. Only participants can retrieve the exact address. `GET /requests/:id/items` and `GET /requests/:id/locations` remain available within those privacy rules.
- `POST /delivers/new` with `{"request_id":123}` returns 200 when accepted and 409 for an already assigned, expired, or self-owned request. `GET /delivers` lists the signed-in courier's assignments. Delivery details and old receipt URLs are visible to participants only.
- `cost` and `fees` are decimal amounts; clients should decode either a decimal string or JSON number. Request IDs are integers and user IDs are UUIDs.
- Web forms use Rails CSRF tokens. New uploads are served through a same-origin image URL; previously stored HTTPS profile-picture links are still recognized on web. Clients may choose not to load legacy off-origin images.

## Before deploying

1. Back up the application database and restore it to staging. Use a currently supported, configured MySQL server with a native MySQL client installed to build `mysql2` (for example `default-libmysqlclient-dev` on Debian/Ubuntu). Set `DATABASE_URL`, or keep the legacy `RDS_DB_NAME`, `RDS_USERNAME`, `RDS_PASSWORD`, `RDS_HOSTNAME` and optional `RDS_PORT` environment. Verify repository migrations against the **staging copy**, not the live database first. If duplicate delivery assignments already exist, the migration stops with a count and does not delete data; reconcile those records before retrying.
2. Supply `SECRET_KEY_BASE` or Rails credentials via your deployment secret store, and set `APP_HOST` (hostname only). Serve the app over HTTPS and have the proxy forward the HTTPS scheme. Production cookies require HTTPS. Old sign-ins and outstanding reset links are not migrated; users sign in or request a new link once.
3. For production email, configure `MAIL_FROM`, `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER` and `SMTP_PASSWORD` as applicable. Without SMTP configured, no production mail is sent. For avatars, use persistent local storage or set `S3_BUCKET` and `AWS_REGION` and supply AWS credentials through the runtime IAM role/standard AWS provider chain. The configured bucket must allow the application to access its objects; public ACLs are not required. Confirm SMTP, S3 and the optional Google Maps integration on staging.
4. Build assets with `RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile`. On the staged database run `RAILS_ENV=production bin/rails db:prepare`, start Puma using the platform's configured host/port (set `BIND_HOST` and `PORT` for `bundle exec puma`), and test browser and mobile sign-in, posting, and accepting. Consider a shared rate-limit cache for a multi-instance deployment; the default is per process. Schedule `bin/rails delivmy:prune_sessions` in your deployment to clean up expired sessions.
5. Roll the Rails and iOS releases out together; the old iOS app's direct cookie/HTTP behavior is no longer accepted for native authentication. There is no checkout, in-app payment, receipt creation, or delivery-completion backend in this repository; the previous web placeholders did not implement those workflows.

`db/schema.rb` is committed using MySQL-compatible bigint references and can be loaded by SQLite. When updating it later, review the Active Storage foreign-key column types before committing an SQLite-generated dump.

Bootstrap CSS is vendored under its MIT license (see `vendor/assets/stylesheets/bootstrap-LICENSE.txt`). No Bootstrap JavaScript, jQuery, or CoffeeScript build is required.
