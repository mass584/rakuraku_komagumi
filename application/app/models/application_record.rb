class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def rails_blob_path(blob, options = {})
    Rails.application.routes.url_helpers.rails_blob_path(blob, options)
  end
end
