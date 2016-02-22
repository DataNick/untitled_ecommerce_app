require "test_helper"

class CartTest < MiniTest::Test

  def test_adds_one_item
    cart = Cart.new
    cart.add_item(1)

    assert_equal cart.empty?, false
  end

end