require "test_helper"

class ProductsTest < ActionDispatch::IntegrationTest
  setup do
    # Create test products
    @product1 = Product.create!(
      name: "Test Product 1",
      category: "electronics",
      description: "A test product",
      price_cents: 1999,
      inventory_count: 10,
      active: true
    )

    @product2 = Product.create!(
      name: "Test Product 2",
      category: "books",
      description: "Another test product",
      price_cents: 2999,
      inventory_count: 5,
      active: true
    )

    @inactive_product = Product.create!(
      name: "Inactive Product",
      category: "electronics",
      description: "Should not appear",
      price_cents: 9999,
      inventory_count: 0,
      active: false
    )
  end

  test "GET /products returns list of active products with pagination" do
    get "/products"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 2, json["products"].length
    assert json["pagination"]["total_count"] >= 2
    assert_equal 1, json["pagination"]["page"]
  end

  test "GET /products filters by category" do
    get "/products?category=electronics"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["products"].length
    assert_equal "electronics", json["products"][0]["category"]
  end

  test "GET /products searches by name" do
    get "/products?query=Test+Product+1"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["products"].length
    assert_equal "Test Product 1", json["products"][0]["name"]
  end

  test "GET /products paginates results" do
    get "/products?page=1&limit=1"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["products"].length
    assert_equal 1, json["pagination"]["limit"]
  end

  test "GET /products excludes inactive products" do
    get "/products"
    assert_response :success

    json = JSON.parse(response.body)
    product_names = json["products"].map { |p| p["name"] }
    assert_not_includes product_names, "Inactive Product"
  end

  test "GET /products/:id returns a product" do
    get "/products/#{@product1.id}"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @product1.id.to_s, json["id"]
    assert_equal "Test Product 1", json["name"]
    assert_equal "electronics", json["category"]
    assert_equal 1999, json["price_cents"]
    assert_equal 10, json["inventory_count"]
  end

  test "GET /products/:id returns 404 for non-existent product" do
    get "/products/507f1f77bcf86cd799439011"
    assert_response :not_found

    json = JSON.parse(response.body)
    assert json["error"]
  end

  test "GET /products/:id returns 404 for inactive product" do
    get "/products/#{@inactive_product.id}"
    assert_response :not_found
  end

  test "product JSON includes all required fields" do
    get "/products/#{@product1.id}"
    assert_response :success

    json = JSON.parse(response.body)
    assert json.key?("id")
    assert json.key?("name")
    assert json.key?("category")
    assert json.key?("description")
    assert json.key?("price_cents")
    assert json.key?("inventory_count")
  end
end
