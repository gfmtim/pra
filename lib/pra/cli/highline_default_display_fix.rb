class HighLine::Question
  alias_method :old_append_default, :append_default

  def append_default
    old_append_default
    @question.sub!(/\|(.+)\|(\s*)\Z/, "(default: \\1)\\2")
  end
end