defmodule PhxTicketsWeb.CommonUtils do
  def format_date(date, show_time \\ false) do
    dt = Timex.to_datetime(date, "Asia/Kolkata")
    format_str = if show_time do
      "%A, %B %d, %Y at %H:%M"
    else
      "%A, %B %d, %Y"
    end
    Calendar.strftime(dt, format_str)
  end
end
