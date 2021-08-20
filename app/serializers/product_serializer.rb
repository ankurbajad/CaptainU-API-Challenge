class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :volume, :weight, :supply_chain_id
end
