require "test_helper"

class CheckoutsTest < ActionDispatch::IntegrationTest
  setup do
    @product1 = Product.create!(
      name: "Widget",
      category: "gadgets",
      description: "A useful widget",
      price_cents: 1000,
      inventory_count: 10,
      active: true
    )

    @product2 = Product.create!(
      name: "Gadget",
      category: "gadgets",
      description: "A cool gadget",
      price_cents: 2000,
      inventory_count: 5,
      active: true
    )

    @low_stock_product = Product.create!(
      name: "Limited Item",
      category: "gadgets",
      description: "Only 2 left",
      price_cents: 5000,
      inventory_count: 2,
      active: true
    )
  end

  test "POST /checkouts/quote returns cart calculation" do
    post "/checkouts/quote", params: {
      items: [
        { product_id: @product1.id.to_s, quantity: 2 }
      ]
    }, as: :json

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 2000, json["subtotal_cents"]
    assert_equal 160, json["tax_cents"] # 8% tax
    assert_equal 2160, json["total_cents"]
    assert_equal 1, json["items"].length
    assert_equal @product1.id.to_s, json["items"][0]["product_id"]
    assert_equal "Widget", json["items"][0]["name"]
    assert_equal 2, json["items"][0]["quantity"]
  end

  test "POST /checkouts/quote handles multiple items" do
    post "/checkouts/quote", params: {
      items: [
        { product_id: @product1.id.to_s, quantity: 1 },
        { product_id: @product2.id.to_s, quantity: 2 }
      ]
    }, as: :json

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 5000, json["subtotal_cents"] # 1000 + 2000*2
    assert_equal 400, json["tax_cents"]
    assert_equal 5400, json["total_cents"]
    assert_equal 2, json["items"].length
  end

  test "POST /checkouts/quote returns 400 for empty cart" do
    post "/checkouts/quote", params: { items: [] }, as: :json

    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "Cart is empty", json["message"]
  end

  test "POST /checkouts/quote returns 400 for invalid product" do
    post "/checkouts/quote", params: {
      items: [
        { product_id: "507f1f77bcf86cd799439011", quantity: 1 }
      ]
    }, as: :json

    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "Product not found", json["message"]
  end

  test "POST /checkouts/quote returns 400 for invalid quantity" do
    post "/checkouts/quote", params: {
      items: [
        { product_id: @product1.id.to_s, quantity: 0 }
      ]
    }, as: :json

    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "Invalid quantity", json["message"]
  end

  test "POST /checkouts/quote returns 400 for insufficient inventory" do
    post "/checkouts/quote", params: {
      items: [
        { product_id: @low_stock_product.id.to_s, quantity: 10 }
      ]
    }, as: :json

    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "Insufficient inventory", json["message"]
  end

  test "POST /checkouts/complete creates order and reduces inventory" do
    initial_inventory = @product1.inventory_count

    post "/checkouts/complete", params: {
      email: "customer@example.com",
      items: [
        { product_id: @product1.id.to_s, quantity: 2 }
      ]
    }, as: :json

    assert_response :created

    json = JSON.parse(response.body)
    assert json["order_id"]
    assert_equal 2160, json["total_cents"]

    # Check order was created
    order = Order.find(json["order_id"])
    assert_equal "customer@example.com", order.email
    assert_equal "completed", order.status
    assert_equal 2000, order.subtotal_cents
    assert_equal 160, order.tax_cents
    assert_equal 2160, order.total_cents
    assert_equal 1, order.items.length

    # Check inventory was reduced
    @product1.reload
    assert_equal initial_inventory - 2, @product1.inventory_count
  end

  test "POST /checkouts/complete handles multiple items" do
    post "/checkouts/complete", params: {
      email: "buyer@example.com",
      items: [
        { product_id: @product1.id.to_s, quantity: 1 },
        { product_id: @product2.id.to_s, quantity: 1 }
      ]
    }, as: :json

    assert_response :created

    json = JSON.parse(response.body)
    order = Order.find(json["order_id"])
    assert_equal 2, order.items.length
    assert_equal 3000, order.subtotal_cents
  end

  test "POST /checkouts/complete returns 400 for empty cart" do
    post "/checkouts/complete", params: {
      email: "test@example.com",
      items: []
    }, as: :json

    assert_response :bad_request
  end

  test "POST /checkouts/complete validates email format" do
    # Mongoid will validate email format through the model
    post "/checkouts/complete", params: {
      email: "invalid-email",
      items: [
        { product_id: @product1.id.to_s, quantity: 1 }
      ]
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "tax calculation is correct at 8 percent" do
    post "/checkouts/quote", params: {
      items: [
        { product_id: @product1.id.to_s, quantity: 1 }
      ]
    }, as: :json

    json = JSON.parse(response.body)
    expected_tax = (json["subtotal_cents"] * 0.08).round
    assert_equal expected_tax, json["tax_cents"]
  end
end
