# Bones73k

## Configuring:

### Global app config

You'll need to configure Time Zone and Mailer reply-from/to like so:

```elixir
# Custom application global variables
config :bones73k, :app_global_vars,
  time_zone: "America/New_York",
  mailer_reply_to: "reply_to@example.com",
  mailer_from: "app_name@example.com"
```

### Mailer Config:

For mailing, Bamboo must be configured. There is no default config, you should put appropriate config in `prod.secret.exs` (or `dev.secret.exs`).

I use SMTP like so (example is for [Pobox](https://www.pobox.com/)):

```elixir
config :bones73k, Bones73k.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.pobox.com",
  hostname: "pobox.com",
  port: 587,
  username: "your_smtp_username", # or {:system, "SMTP_USERNAME"}
  password: "your_smtp_password", # or {:system, "SMTP_PASSWORD"}
  ssl: false, # can be `true`; pobox.com failed when this came after tls and was set to `true`
  tls: :always, # can be `:always` or `:never`
  allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :always # can be `:always`. If your smtp relay requires authentication set it to `:always`.
```

Or provide an expanded config for a different mailer as desired.


## TODO

Nothing right now!