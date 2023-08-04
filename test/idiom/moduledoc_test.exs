defmodule Idiom.ModuledocTest do
  # Tests from Idiom's moduledoc to make sure the examples are actually working

  use ExUnit.Case, async: true
  alias Idiom.Cache
  import Idiom

  test "Locales - Resolution hierarchy" do
    data =
      Jason.decode!("""
        {
          "en": {
            "default": {
              "Create your account": "Create your account"
            }
          },
          "en-US": {
            "default": {
              "Take the elevator": "Take the elevator"
            }
          },
          "en-GB": {
            "default": {
              "Take the elevator": "Take the lift"
            }
          }
        }
      """)

    Cache.init(data, :locales_resolution_hierarchy_test)

    assert t("Take the elevator", to: "en-US", cache_table_name: :locales_resolution_hierarchy_test) == "Take the elevator"
    assert t("Take the elevator", to: "en-GB", cache_table_name: :locales_resolution_hierarchy_test) == "Take the lift"
    assert t("Create your account", to: "en-US", cache_table_name: :locales_resolution_hierarchy_test) == "Create your account"
    assert t("Create your account", to: "en-GB", cache_table_name: :locales_resolution_hierarchy_test) == "Create your account"
  end

  test "Locales - Fallback locales" do
    data = %{
      "en" => %{"default" => %{"Key that is only available in `en` and `fr`" => "en"}},
      "fr" => %{"default" => %{"Key that is only available in `en` and `fr`" => "fr"}}
    }

    Cache.init(data, :locales_fallback_locales_test)

    assert t("Key that is only available in `en` and `fr`", to: "es", fallback: "en", cache_table_name: :locales_fallback_locales_test) == "en"
    assert t("Key that is only available in `en` and `fr`", to: "es", fallback: ["fr", "en"], cache_table_name: :locales_fallback_locales_test) == "fr"
    assert t("Key that is only available in `en` and `fr`", to: "es", cache_table_name: :locales_fallback_locales_test) == "en"
    assert t("Key that is not available in any locale", to: "es", cache_table_name: :locales_fallback_locales_test) == "Key that is not available in any locale"
  end

  test "Namespaces" do
    data = %{"en" => %{"signup" => %{"Create your account" => "Create your account"}}}

    Cache.init(data, :namespaces_test)

    assert t("Create your account", namespace: "signup", cache_table_name: :namespaces_test) == "Create your account"
    assert t("signup:Create your account", cache_table_name: :namespaces_test) == "Create your account"

    Idiom.put_namespace("signup")
    assert t("Create your account", cache_table_name: :namespaces_test) == "Create your account"
  end

  test "Namespaces - Namespace prefixes and natural language keys" do
    data = %{"en" => %{"default" => %{"Get started on GitHub: create your account" => "message"}}}

    Cache.init(data, :namespace_prefixes_test)

    assert t("Get started on GitHub: create your account", namespace: "default", cache_table_name: :namespace_prefixes_test) == "message"
    assert t("Get started on GitHub: create your account", namespace_separator: "|", cache_table_name: :namespace_prefixes_test) == "message"
  end

  test "Interpolation" do
    data =
      Jason.decode!("""
        {
          "en": {
            "default": {
              "Welcome, {{name}}": "Welcome, {{name}}",
              "It is currently {{temperature}} degrees in {{city}}": "It is currently {{temperature}} degrees in {{city}}"
            }
          }
        }
      """)

    Cache.init(data, :interpolation_test)

    assert t("Welcome, {{name}}", %{name: "Tim"}, cache_table_name: :interpolation_test) == "Welcome, Tim"

    assert t("It is currently {{temperature}} degrees in {{city}}", %{temperature: "31", city: "Hong Kong"}, cache_table_name: :interpolation_test) ==
             "It is currently 31 degrees in Hong Kong"
  end
end