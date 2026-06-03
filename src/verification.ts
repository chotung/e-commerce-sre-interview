// API Verification Script for E-commerce API

const API_BASE_URL = process.env.API_BASE_URL || "http://localhost:3000";

interface Product {
  id: string;
  name: string;
  category: string;
  description: string;
  price_cents: number;
  inventory_count: number;
}

interface ProductsResponse {
  products: Product[];
  pagination: {
    page: number;
    limit: number;
    total_count: number;
  };
}

interface CheckoutQuoteResponse {
  items: Array<{
    product_id: string;
    name: string;
    quantity: number;
    unit_price_cents: number;
    total_cents: number;
  }>;
  subtotal_cents: number;
  tax_cents: number;
  total_cents: number;
}

interface CheckoutCompleteResponse {
  order_id: string;
  total_cents: number;
}

async function verify(): Promise<void> {
  console.log("Starting API verification...\n");

  try {
    // Test 1: List products
    console.log("Test 1: GET /products");
    const productsRes = await fetch(`${API_BASE_URL}/products`);
    if (productsRes.status !== 200) throw new Error(`Expected 200, got ${productsRes.status}`);

    const productsData = await productsRes.json() as ProductsResponse;
    if (productsData.products.length === 0) throw new Error("No products found. Run db:seed first.");

    console.log(`[PASS] Found ${productsData.products.length} products\n`);

    // Test 2: Get single product
    const testProduct = productsData.products[0];
    console.log(`Test 2: GET /products/${testProduct.id}`);
    const productRes = await fetch(`${API_BASE_URL}/products/${testProduct.id}`);
    if (productRes.status !== 200) throw new Error(`Expected 200, got ${productRes.status}`);

    const product = await productRes.json() as Product;
    console.log(`[PASS] Product: ${product.name} - $${(product.price_cents / 100).toFixed(2)}\n`);

    // Test 3: Filter by category
    console.log("Test 3: GET /products?category=electronics");
    const filterRes = await fetch(`${API_BASE_URL}/products?category=electronics`);
    if (filterRes.status !== 200) throw new Error(`Expected 200, got ${filterRes.status}`);

    const filtered = await filterRes.json() as ProductsResponse;
    console.log(`[PASS] Found ${filtered.products.length} electronics\n`);

    // Test 4: Get quote
    console.log("Test 4: POST /checkouts/quote");
    const quoteRes = await fetch(`${API_BASE_URL}/checkouts/quote`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        items: [{ product_id: testProduct.id, quantity: 2 }]
      })
    });
    if (quoteRes.status !== 200) throw new Error(`Expected 200, got ${quoteRes.status}`);

    const quote = await quoteRes.json() as CheckoutQuoteResponse;
    console.log(`[PASS] Quote: $${(quote.total_cents / 100).toFixed(2)} (subtotal + 8% tax)\n`);

    // Test 5: Complete checkout
    console.log("Test 5: POST /checkouts/complete");
    const orderRes = await fetch(`${API_BASE_URL}/checkouts/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: "test@example.com",
        items: [{ product_id: testProduct.id, quantity: 2 }]
      })
    });
    if (orderRes.status !== 201) throw new Error(`Expected 201, got ${orderRes.status}`);

    const order = await orderRes.json() as CheckoutCompleteResponse;
    console.log(`[PASS] Order created: ${order.order_id}\n`);

    // Test 6: Error handling - 404
    console.log("Test 6: GET /products/invalid-id (error test)");
    const notFoundRes = await fetch(`${API_BASE_URL}/products/507f1f77bcf86cd799439011`);
    if (notFoundRes.status !== 404) throw new Error(`Expected 404, got ${notFoundRes.status}`);
    console.log(`[PASS] 404 handled correctly\n`);

    // Test 7: Error handling - empty cart
    console.log("Test 7: POST /checkouts/quote with empty cart (error test)");
    const emptyRes = await fetch(`${API_BASE_URL}/checkouts/quote`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ items: [] })
    });
    if (emptyRes.status !== 400) throw new Error(`Expected 400, got ${emptyRes.status}`);
    console.log(`[PASS] Empty cart validation works\n`);

    console.log("All tests passed!");
    process.exit(0);
  } catch (error) {
    console.error("\n[FAIL] Verification failed:");
    console.error(error instanceof Error ? error.message : error);
    process.exit(1);
  }
}

verify();
