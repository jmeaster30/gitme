# gitme

My own git server repo manager thingy

## API Configuration

The API looks for the configuration file in these paths and prioritizes this order:
1. `./gitme.toml`
2. `~/.gitme/gitme.toml`
3. `~/.config/gitme.toml`
4. `/etc/gitme/gitme.toml`

```
[jwt]
signing=<path to the RS256 pem signing key>
verify=<path to the RS256 pem verify key>

[session]
secret=<securely randomly generated secure secret that is at least 64 characters>

[db]
path=<path to the sqlite3 database file>

[git.repository]
path=<path where all the git repositories will be stored>
```

## Ideas

- API (ruby)
  - This will be a rest api that handles authentication and has routes to CRUD repositories, branches, issues etc. etc.
  - configure API to sync with other git server providers (like github)
- CLI (clojure)
  - This is a CLI client that just calls the api endpoints
- WEB
  - web interface to have a nice UI for the API
  - I need cool graphs
  - language
    - ReactJS meh I have used it before
    - Svelte neat
    - Elm neat and(but) functional
