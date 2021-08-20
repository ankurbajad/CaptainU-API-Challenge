class ImportSupplyChainJob < ActiveJob::Base
  # include ImportSupplyChainData
  queue_as :default

  def perform(file_ids, user_id)
    response = ImportSupplyChainData.call(file_ids, user_id)
    if response[0]
      user = User.find_by(id: response[1])
      NotifierMailer.import_status(user, response[0]).deliver
    end
  end
end