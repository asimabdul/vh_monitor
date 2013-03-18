class String
  def is_json?
    JSON.parse(self)
    true
  rescue JSON::ParserError
    false
  end
end