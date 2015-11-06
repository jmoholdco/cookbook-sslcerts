class DummySigned
  attr_reader :data_bag_item
  def initialize(options = {})
    @outbox = options[:outbox]
    @certificate = options[:cert] || options[:certificate]
    @data_bag_item = Chef::DataBagItem.from_hash(to_h).tap do |bag|
      bag.data_bag 'certificates'
    end
  end

  def to_h
    {
      'id' => @outbox.id,
      'certificate' => @certificate.to_pem,
      'hostname' => @outbox.hostname
    }
  end
end

class DummyOutbox
  attr_reader :hostname, :id, :csr, :key, :days, :type
  attr_accessor :signed
  def initialize(options = {})
    @hostname = options[:hostname]
    @id = options[:id]
    @csr = options[:csr]
    @key = options[:key]
    @signed = false
    @days = (365 * 5)
    @type = options[:type] || 'server'
  end

  def signing_args
    [csr, type, days]
  end

  def to_h # rubocop:disable Metrics/MethodLength
    {
      id => {
        id: id,
        csr: csr.to_pem,
        date: Time.now.to_s,
        type: 'server',
        days: days,
        signed: signed,
        hostname: hostname
      }
    }
  end
end
