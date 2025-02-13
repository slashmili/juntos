defmodule Juntos.Accounts.UserNotifier do
  import Swoosh.Email

  alias Juntos.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Juntos", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_otp_code(user, otp_token, url) do
    otp_code = String.slice(otp_token, 0, 6)

    deliver(user.email, "OTP instructions", """

    ==============================

    Hi #{user.name},

    You can confirm your account by entering the following One-Time-Code:

    #{otp_code}

    or by visting this URL:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end
end
