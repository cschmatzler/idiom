# Changelog

## 0.6.8 (2024-05-01)
### Bug Fixes
* Fixes crash when not setting `otp_app` in configuration.

## 0.6.7 (2024-04-23)
### Bug Fixes
* Fixes crash when passing `nil` to `t/3`.

## 0.6.6 (2024-04-08)

### Features

* Updates plural definitions: now supports the `blo` language code for plurals

### Maintenance

* Updates dependencies
* Removes deprecation warnings for Elixir 1.16

## 0.6.5 (2023-10-03)

### Features

* Allow interpolation binding keys to be strings (ab5d78c)
```elixir
t("It is {{month}} {{day}}, {{year}}", %{"month" => "February", "day" => 3, year: 2023})
```

### Bug Fixes

* Fixes some functions being called multiple times (2260079)
