require 'xml/libxml'
require 'zip'

module Mswallet
  class Pass
    TYPES = %W(Deal General PaymentInstrument Ticket BoardingPass MembershipCard )

    attr_accessor :pass, :files, :locales

    def initialize(pass = nil)
      @pass = pass || self.class.init
      @locales = {}
      @files = []
      yield(self) if block_given?
    end

    def []=(key, val)
      el = XML::Node.new(key)
      el.content = val
      @pass.root << el
      el
    end

    def [](key)
      @pass.root.find(key).first
    end

    def add_file(file)
      @files << file
    end

    def add_locale(lang, file)
      @locales[lang] = file
    end

    # Return a Tempfile containing our ZipStream
    def file(options = {})
      options[:file_name] ||= 'pass.mswallet'
      temp_file = Tempfile.new(options[:file_name])
      temp_file.write self.stream.string
      temp_file.close
      temp_file
    end
    # Return a ZipOutputStream
    def stream
      check_pass
      output_zip
    end

    def self.init
      doc = XML::Document.new
      doc.encoding = XML::Encoding::UTF_8
      root = XML::Node.new 'WalletItem'
      doc.root = root

      version_el = XML::Node.new('Version')
      version_el.content = WALLET_VERSION
      root << version_el

      return doc
    end

    private

    def check_pass
# Check for default images
      [99, 159, 336].each do |size|
        raise "Logo#{size}x#{size} missing" unless @files.detect {|f| f[:name] == "Logo#{size}x#{size}.png" }
      end

# Check for developer field in XML

      fail 'Pass must be XML::Document object' unless @pass.is_a? XML::Document

      root = @pass.find('WalletItem')

      fail 'WalletItem node missing' unless root

      {
          'Version' => ['Format Version missing', Mswallet::WALLET_VERSION ],
          'Kind' => ['Pass Kind Identifier missing', TYPES ],
          'Id' => ['Id missing'],
          'DisplayName' => ['Display Name missing' ],
          'IssuerDisplayName' => ['Issuer Display Name missing'],
          'HeaderColor' => ['Header Color missing', /^#(?:[\da-fA-F]{2}){3}$/],
          'BodyColor' => ['Body Name missing', /#(?:[\d\w]){3}/]

      }.each do |tag, params|
        msg, value = params
        el = @pass.find(tag).first
        fail msg unless el

        case value
          when Array
            fail "#{tag} not in #{value.join(',')}" unless value.include?(el.content) unless value.empty?
          when Regexp
            fail "#{tag} not match #{value.to_s}" unless el.content.match value
          when nil
            nil
          else
            fail "#{tag} must be #{value}" unless value == el.content
        end
      end

    end

    def output_zip
      buffer = Zip::OutputStream.write_buffer do |zip|
        zip.put_next_entry 'WalletItem.xml'
        zip.write @pass.to_s

        @files.each do |file|
          if file.class == Hash
            zip.put_next_entry file[:name]
            zip.print file[:content]
          else
            zip.put_next_entry File.basename(file)
            zip.print IO.read(file)
          end
        end

        @locales.each do |lang, file|
          zip.put_next_entry "#{lang}/strings.txt"

          data = ''
          case file
            when String
              data = file
            when File
              data = file.read
            when Hash
              file.each do |k, v|
                data += "#{k}=#{v}\n"
              end
            else
              fail 'wrong locale object'
          end

          zip.print data
        end
      end
      
      buffer
    end

  end
end