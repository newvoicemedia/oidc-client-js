# Extensions for core String class
class String
  def yellow
    colorize(self, "\e[1m\e[33m")
  end

  def colorize(text, color_code)
    "#{color_code}#{text}\e[0m"
  end
end
