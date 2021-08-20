class ProductsSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :cube_size, :weight, :supply_chain_id
end
