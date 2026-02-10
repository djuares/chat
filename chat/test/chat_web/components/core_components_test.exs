defmodule ChatWeb.CoreComponentsTest do
  use ChatWeb.ConnCase, async: true
  use ChatWeb, :html

  import Phoenix.LiveViewTest
  import ChatWeb.CoreComponents

  describe "flash/1" do
    test "renders info flash message" do
      assigns = %{
        flash: %{"info" => "Hello!"}
      }

      html =
        rendered_to_string(~H"""
        <.flash kind={:info} />
        """)

      assert html =~ ""
    end

    test "renders error flash message" do
      assigns = %{
        flash: %{"error" => "Boom"}
      }

      html =
        rendered_to_string(~H"""
        <.flash kind={:error} />
        """)

      assert html =~ ""
    end
  end

  describe "input/1" do
    test "renders input errors" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.input
          type="text"
          name="email"
          value=""
          errors={["is invalid"]}
        />
        """)

      assert html =~ "is invalid"
    end
  end
end
