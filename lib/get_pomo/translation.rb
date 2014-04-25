module GetPomo
  class Translation
    FUZZY_REGEX = /^#,\s*fuzzy/
    OBSOLETE_REGEX = /^#~\s*msgstr/
    attr_accessor :msgid, :msgstr, :msgctxt, :comment

    def add_text(text,options)
      to = options[:to]
      if to.to_sym == :msgid_plural
        self.msgid = [msgid] unless msgid.is_a? Array
        msgid[1] = msgid[1].to_s + text
      elsif to.to_s =~ /^msgstr\[(\d)\]$/
        self.msgstr ||= []
        msgstr[$1.to_i] = msgstr[$1.to_i].to_s + text
      else
        #simple form
        send("#{to}=",send(to).to_s+text)
      end
    end

    def to_hash
      {:msgctxt=>msgctxt,:msgid=>msgid,:msgstr=>msgstr,:comment=>comment}.reject{|k,value|value.nil?}
    end

    def complete?
      (not msgid.nil? and not msgstr.nil?) or obsolete?
    end

    def fuzzy?
      !!(comment =~ FUZZY_REGEX)
    end

    def obsolete?
      obs = if !!(comment =~ OBSOLETE_REGEX)
        #prevent nullpointer in obsolete msgs
        self.msgid = ''
        self.msgstr = ''
      end
      obs
    end

    def fuzzy=(value)
      if value and not fuzzy?
        add_text "\n#, fuzzy", :to=>:comment
      else
        self.comment = comment.to_s.split(/$/).reject{|line|line=~FUZZY_REGEX}.join("\n")
      end
    end

    def plural?
      msgid.is_a? Array or msgstr.is_a? Array
    end

    def singular?
      !plural?
    end

    def header?
      msgid == ""
    end
  end
end
