module EaSSL
  class Serial
    def export
      format('%04X', @next)
    end

    def save!
      return export unless @path
      File.open(@path, 'w') do |io|
        io.write "#{export}\n"
      end
    end
  end

  class CertificateName
    def to_h
      @options
    end

    def to_hash
      @options
    end
  end
end
