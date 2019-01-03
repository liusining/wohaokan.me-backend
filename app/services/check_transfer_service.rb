class CheckTransferService
  URL =  'https://api.mixin.one/transfers/trace/'.freeze
  def initialize(issuer, order)
    @issuer = issuer
    @order = order
  end

  def perform
    Rails.logger.tagged('CheckTransferService'.freeze) {|logger| logger.info "begin checking a transfer"}
    start_time = Time.now
    resp = RestClient.get("#{URL}#{@order.trace_id}", {Authorization: "Bearer #{@issuer.access_token}"}) {|res, _req, _result| res}
    Rails.logger.tagged('CheckTransferService'.freeze) {|logger| logger.info "mixin response: #{resp}"}
    resp_hash = JSON.parse(resp.body)
    Rails.logger.tagged('CheckTransferService'.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    valid_payment?(resp_hash)
  end

  private

  def valid_payment?(resp_hash)
    data = resp_hash['data']
    data['type'] == 'transfer' &&
      data['opponent_id'] == Order::WOHAOKANME_CLIENT_ID &&
      data['asset_id'] == Order::EOS_ASSET_ID &&
      data['amount'] == "-#{Order::AMOUNT}"
  rescue NoMethodError => ex
    Rails.logger.tagged('CheckTransferService'.freeze) {|logger| logger.info "cannot parse response: #{ex.message}"}
    false
  end
end