%%{
  machine re_property;

  property_char     = [pP];

  property_sequence = property_char . '{' . '^'? (alnum|space|[_\-\.=])+ '}';

  action premature_property_end {
    raise PrematureEndError.new('unicode property')
  }

  # Unicode properties scanner
  # --------------------------------------------------------------------------
  unicode_property := |*

    property_sequence < eof(premature_property_end) {
      text = text(data, ts, te, 1).first
      if in_set
        type = :set
      else
        type = (text[1] == 'P') ^ (text[3] == '^') ? :nonproperty : :property
      end

      name = data[ts+2..te-2].pack('c*').gsub(/[\^\s_\-]/, '').downcase

      token = self.class.short_prop_map[name] || self.class.long_prop_map[name]
      raise UnknownUnicodePropertyError.new(name) unless token

      self.emit(type, token.to_sym, text, ts-1, te)

      fret;
    };
  *|;
}%%
