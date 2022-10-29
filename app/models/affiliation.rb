class Affiliation < ApplicationRecord
    validates :cliente, :manager, presence: true
    #validates :cliente, :manager, :azienda, presence: true

end
