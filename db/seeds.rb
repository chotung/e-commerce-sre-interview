# Clear existing data
puts "Clearing existing products..."
Product.destroy_all

puts "Creating products..."

# Electronics
Product.create!([
  {
    name: "Wireless Bluetooth Headphones",
    category: "electronics",
    description: "Premium noise-canceling headphones with 30-hour battery life",
    price_cents: 12999,
    inventory_count: 50,
    active: true
  },
  {
    name: "4K Smart TV 55 inch",
    category: "electronics",
    description: "Ultra HD smart TV with HDR and streaming apps",
    price_cents: 59999,
    inventory_count: 15,
    active: true
  },
  {
    name: "USB-C Charging Cable",
    category: "electronics",
    description: "Fast charging USB-C cable, 6ft length",
    price_cents: 1499,
    inventory_count: 200,
    active: true
  },
  {
    name: "Wireless Mouse",
    category: "electronics",
    description: "Ergonomic wireless mouse with precision tracking",
    price_cents: 2999,
    inventory_count: 75,
    active: true
  },
  {
    name: "Laptop Stand",
    category: "electronics",
    description: "Adjustable aluminum laptop stand for better ergonomics",
    price_cents: 4999,
    inventory_count: 30,
    active: true
  }
])

# Books
Product.create!([
  {
    name: "The Ruby Programming Language",
    category: "books",
    description: "Comprehensive guide to Ruby programming",
    price_cents: 3999,
    inventory_count: 25,
    active: true
  },
  {
    name: "MongoDB: The Definitive Guide",
    category: "books",
    description: "Complete reference for MongoDB database",
    price_cents: 4499,
    inventory_count: 18,
    active: true
  },
  {
    name: "Clean Code",
    category: "books",
    description: "A handbook of agile software craftsmanship",
    price_cents: 3499,
    inventory_count: 40,
    active: true
  },
  {
    name: "The Pragmatic Programmer",
    category: "books",
    description: "Journey to software mastery",
    price_cents: 4299,
    inventory_count: 32,
    active: true
  }
])

# Clothing
Product.create!([
  {
    name: "Cotton T-Shirt",
    category: "clothing",
    description: "100% organic cotton t-shirt, available in multiple colors",
    price_cents: 1999,
    inventory_count: 150,
    active: true
  },
  {
    name: "Denim Jeans",
    category: "clothing",
    description: "Classic fit denim jeans with stretch comfort",
    price_cents: 5999,
    inventory_count: 80,
    active: true
  },
  {
    name: "Hooded Sweatshirt",
    category: "clothing",
    description: "Cozy fleece-lined hoodie for cold weather",
    price_cents: 4499,
    inventory_count: 60,
    active: true
  },
  {
    name: "Running Shoes",
    category: "clothing",
    description: "Lightweight running shoes with cushioned sole",
    price_cents: 8999,
    inventory_count: 45,
    active: true
  },
  {
    name: "Winter Jacket",
    category: "clothing",
    description: "Insulated winter jacket with waterproof exterior",
    price_cents: 12999,
    inventory_count: 25,
    active: true
  }
])

# Home & Garden
Product.create!([
  {
    name: "Coffee Maker",
    category: "home",
    description: "Programmable drip coffee maker with thermal carafe",
    price_cents: 7999,
    inventory_count: 35,
    active: true
  },
  {
    name: "Ceramic Plant Pot",
    category: "home",
    description: "Handcrafted ceramic pot for indoor plants",
    price_cents: 2499,
    inventory_count: 100,
    active: true
  },
  {
    name: "LED Desk Lamp",
    category: "home",
    description: "Adjustable LED lamp with USB charging port",
    price_cents: 3999,
    inventory_count: 55,
    active: true
  },
  {
    name: "Throw Pillow Set",
    category: "home",
    description: "Set of 2 decorative throw pillows",
    price_cents: 2999,
    inventory_count: 70,
    active: true
  }
])

# Sports & Outdoors
Product.create!([
  {
    name: "Yoga Mat",
    category: "sports",
    description: "Non-slip yoga mat with carrying strap",
    price_cents: 3499,
    inventory_count: 90,
    active: true
  },
  {
    name: "Water Bottle",
    category: "sports",
    description: "Insulated stainless steel water bottle, 32oz",
    price_cents: 2799,
    inventory_count: 120,
    active: true
  },
  {
    name: "Resistance Bands Set",
    category: "sports",
    description: "Set of 5 resistance bands for home workouts",
    price_cents: 1999,
    inventory_count: 85,
    active: true
  },
  {
    name: "Camping Tent",
    category: "sports",
    description: "4-person waterproof camping tent",
    price_cents: 15999,
    inventory_count: 12,
    active: true
  }
])

# Add some products with low inventory for testing
Product.create!([
  {
    name: "Limited Edition Poster",
    category: "home",
    description: "Collectible art poster, only a few left",
    price_cents: 4999,
    inventory_count: 3,
    active: true
  },
  {
    name: "Vintage Camera",
    category: "electronics",
    description: "Refurbished vintage film camera",
    price_cents: 29999,
    inventory_count: 2,
    active: true
  }
])

# Add some inactive products to test filtering
Product.create!([
  {
    name: "Discontinued Product",
    category: "electronics",
    description: "This product is no longer available",
    price_cents: 9999,
    inventory_count: 0,
    active: false
  },
  {
    name: "Out of Season Item",
    category: "clothing",
    description: "Not currently in stock",
    price_cents: 3999,
    inventory_count: 0,
    active: false
  }
])

puts "Created #{Product.count} products!"
puts "Active products: #{Product.where(active: true).count}"
puts "Categories: #{Product.distinct(:category).join(', ')}"
