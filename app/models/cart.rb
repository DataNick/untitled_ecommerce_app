class Cart

  attr_reader :items #to fix undefined items method in test

  def initialize
    @items = []
  end

  def add_item(product_id)
    item = @items.find{ |item| item.product_id == product_id }
    if item
      item.increment
    else
      @items << CartItem.new(product_id)
    end
  end

  def increment
    @quantity += 1
  end

  def empty?
    @items.empty?
  end

end